package env;

import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.environment.Environment;
import jason.asSemantics.Unifier;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import org.json.JSONObject;

import java.net.InetSocketAddress;
import java.util.HashMap;
import java.util.Iterator;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import java.util.concurrent.locks.ReentrantLock;


public class MinecraftEnv extends Environment {
    SimpleServer server;

    BlockingQueue<String> newPcQueue;
    HashMap<String, LinkedBlockingQueue<String>> newPcQueues;
    HashMap<String, String> ag2pc;
    HashMap<String, String> pc2ag;

    HashMap<String, BlockingQueue<JSONObject>> pcQueues;
    HashMap<String, ReentrantLock> pcLocks;
    

    interface ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj);
    }

    HashMap<String, ExecsAfterEffects> execsMap;


    String escape(String s){
        return s.replaceAll("\"", "\\\"");
    }

    class EmptyEAE implements ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj) {
            return true;
        }
    }

    class ReportEAE implements ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj) {
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_out(X)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_err(X)"));
            if (obj.has("out")) {
                addPercept(ag, Literal.parseLiteral("execs_out(\"" + obj.get("out") + "\")"));
            }
            if (obj.has("err")) {
                addPercept(ag, Literal.parseLiteral("execs_err(\"" + obj.get("err") + "\")"));
                // System.out.println("  XXX "+ obj.get("err"));
            }
            return !obj.has("err");
        }
    }

    class LiteralEAE implements ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj) {
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_out(X)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_err(X)"));
            if (obj.has("out")) {
                addPercept(ag, Literal.parseLiteral("execs_out(" + obj.get("out") + ")"));
                // System.out.println("  XXX "+ obj.get("finished"));
                // System.out.println("  XXX "+ obj.get("out"));
            }
            if (obj.has("err")) {
                addPercept(ag, Literal.parseLiteral("execs_err(\"" + obj.get("err") + "\")"));
                // System.out.println("  XXX "+ obj.get("err"));
            }
            return !obj.has("err");
        }
    }

    class LocationEAE implements ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj) {
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_out(X)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_err(X)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("at(X,Y,Z)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("facing(Dir)"));
            if (obj.has("out")) {
                String out = obj.get("out").toString();
                addPercept(ag, Literal.parseLiteral("execs_out(\"" + out + "\")"));
                if (out.contains(", ")) {
                    String[] parts = out.split(", ");
                    addPercept(ag, Literal.parseLiteral("at(" + parts[0] + ")"));
                    addPercept(ag, Literal.parseLiteral("facing(" + parts[1] + ")"));
                }
            }
            if (obj.has("err")) {
                addPercept(ag, Literal.parseLiteral("execs_err(\"" + obj.get("err") + "\")"));
        }
            return !obj.has("err");
        }
    }

    class InvEAE implements ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj) {
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_out(X)"));
            removePerceptsByUnif(ag, Literal.parseLiteral("execs_err(X)"));
            if (obj.has("out")) {
                String out = obj.get("out").toString();
                // addPercept(ag, Literal.parseLiteral("execs_out(\"" + out + "\")"));
                // loop through map, update only present
                JSONObject outobj = (JSONObject)obj.get("out");
                for (Iterator<String> i = outobj.keys(); i.hasNext(); ) {
                    String key  = i.next();
                    int index = Integer.valueOf(key);
                    JSONObject content = (JSONObject)outobj.get(key);
                    removePerceptsByUnif(ag, Literal.parseLiteral("slot(" + key + ", Name, Count)"));
                    String name = (String)content.get("name");
                    int count = (int)content.get("count");
                    // System.out.println("Agent "+ag+" got inv "+key+" "+name+" "+count);
                    addPercept(ag, Literal.parseLiteral("slot(" +key+", \""+name+"\", "+count+")"));
                }
            }
            if (obj.has("err")) {
                addPercept(ag, Literal.parseLiteral("execs_err(\"" + obj.get("err") + "\")"));
            }
            return !obj.has("err");
        }
    }

    LocationEAE locationEffects;

    @Override
    public void init(String[] args) {
        String host = "localhost";
        int port = 8887;
        int nChannels=10;

        newPcQueue = new LinkedBlockingQueue<String>();
        newPcQueues = new HashMap<String, LinkedBlockingQueue<String>>();
        for (int i=0; i<nChannels; i++) {
            newPcQueues.put(Integer.toString(i), new LinkedBlockingQueue<String>());
        }

        ag2pc = new HashMap<String, String>();
        pc2ag = new HashMap<String, String>();
        pcQueues = new HashMap<String, BlockingQueue<JSONObject>>();
        pcLocks = new HashMap<String, ReentrantLock>();

        server = new SimpleServer(new InetSocketAddress(host, port), newPcQueues);
        server.setReuseAddr(true);
        server.start();

        execsMap = new HashMap<String, ExecsAfterEffects>();

        execsMap.put("execs", new ReportEAE());
        execsMap.put("execs_literal", new LiteralEAE());
        execsMap.put("inv", new InvEAE());

        locationEffects = new LocationEAE();
    }

    boolean a_connect(String ag, String channel) {
        String pc;
        if (!newPcQueues.containsKey(channel)) return false;
        
        try {
            pc = newPcQueues.get(channel).take();
        } catch (InterruptedException e) { return false; }

        ag2pc.put(ag, pc);
        pc2ag.put(pc, ag);
        pcQueues.put(pc, new LinkedBlockingQueue<JSONObject>());
        pcLocks.put(pc, new ReentrantLock());

        boolean retval = server.acceptConnection(ag, pc, pcQueues.get(pc));
        if (!retval) { return false; }

        addPercept(ag, Literal.parseLiteral("connected"));
        addPercept(ag, Literal.parseLiteral("pc(\"" + pc + "\")"));

        return retval;
    }

    boolean a_exec(String ag, String action) {
        JSONObject json = new JSONObject();
        json.put("func", "return " + action);
        String pc = ag2pc.get(ag);
        return server.exec(pc, json);
    }

    boolean a_execs(String ag, String action, ExecsAfterEffects effects) {
        JSONObject json = new JSONObject();
        json.put("func", "return " + action);
        json.put("sync", "true");

        String pc = ag2pc.get(ag);
        pcLocks.get(pc).lock();
        boolean retval = server.exec(pc, json);
        if (!retval) { 
            pcLocks.get(pc).unlock();
            return false;
        }

        JSONObject obj;
        try {
            obj = pcQueues.get(pc).take();
        } catch (InterruptedException e) {
            pcLocks.get(pc).unlock();
            return false;
        }

        retval = effects.call(ag, obj);
        pcLocks.get(pc).unlock();
        return retval;
    }

    /**
     * Implementation of the agent's basic actions
     */
    @Override
    public boolean executeAction(String ag, Structure act) {
        // System.out.println("Agent "+ag+" is doing "+act);
        // clearPercepts();

        boolean retval = false;
        String functor = act.getFunctor();

        // execs
        if (execsMap.containsKey(functor)) {
            String literal = act.getTerm(0).toString();
            literal = literal.substring(1, literal.length()-1);

            retval = a_execs(ag, literal, execsMap.get(functor));
        }
        // exec
        else if (functor.equals("exec")) {
            String literal = act.getTerm(0).toString();
            literal = literal.substring(1, literal.length()-1);
            retval = a_exec(ag, literal);
        }
        // locate
        else if (functor.equals("locate")) {
            retval = a_execs(ag, "tst.fullLocate()", locationEffects);
        }
        // longAction
        else if (functor.equals("longAction")) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {}
        } // connect
        else if (functor.equals("connect")) {
            int arity = act.getArity();
            if (arity == 0) {
                retval = a_connect(ag, "0");
            } else {
                String channel = act.getTerm(0).toString();
                channel = channel.substring(1, channel.length()-1);
                retval = a_connect(ag, channel);
            }

            
        }
        if(!retval) {
            // System.out.println("XXX [" + ag + "] action " + act + " FAILED.");
        }

        informAgsEnvironmentChanged();
        return retval;
    }

    public void stop() {
        try {
            server.stop();
        } catch (InterruptedException e) {}
    }
}
