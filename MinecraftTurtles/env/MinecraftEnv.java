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
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;


public class MinecraftEnv extends Environment {
    SimpleServer server;

    BlockingQueue<String> newPcQueue;
    HashMap<String, String> ag2pc;
    HashMap<String, String> pc2ag;

    HashMap<String, BlockingQueue<JSONObject>> pcQueues;

    interface ExecsAfterEffects {
        public boolean call(String ag, JSONObject obj);
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
                if (out.contains("|")) {
                    String[] parts = out.split("\\|");
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

    ReportEAE reportEffects;
    LocationEAE locationEffects;

    @Override
    public void init(String[] args) {
        String host = "localhost";
        int port = 8887;

        newPcQueue = new LinkedBlockingQueue<String>();
        ag2pc = new HashMap<String, String>();
        pc2ag = new HashMap<String, String>();
        pcQueues = new HashMap<String, BlockingQueue<JSONObject>>();

        server = new SimpleServer(new InetSocketAddress(host, port), newPcQueue);
        server.setReuseAddr(true);
        server.start();

        reportEffects = new ReportEAE();
        locationEffects = new LocationEAE();
    }

    boolean a_connect(String ag) {
        String pc;
        try {
            pc = newPcQueue.take();
        } catch (InterruptedException e) { return false; }

        ag2pc.put(ag, pc);
        pc2ag.put(pc, ag);
        pcQueues.put(pc, new LinkedBlockingQueue<JSONObject>());

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
        boolean retval = server.exec(pc, json);
        if (!retval) { return false; }

        JSONObject obj;
        try {
            obj = pcQueues.get(pc).take();
        } catch (InterruptedException e) { return false; }

        return effects.call(ag, obj);
    }

    /**
     * Implementation of the agent's basic actions
     */
    @Override
    public boolean executeAction(String ag, Structure act) {
        // System.out.println("Agent "+ag+" is doing "+act);
        clearPercepts();

        boolean retval = false;

        // exec, execs
        if (act.getFunctor().equals("exec") | act.getFunctor().equals("execs")) {
            JSONObject json = new JSONObject();
            String literal = act.getTerm(0).toString();
            literal = literal.substring(1, literal.length()-1);
            if (act.getFunctor().equals("execs")) {
                retval = a_execs(ag, literal, reportEffects);
            } else {
                retval = a_exec(ag, literal);
            }
        }
        // locate
        else if (act.getFunctor().equals("locate")) {
            JSONObject json = new JSONObject();
            retval = a_execs(ag, "tst.fullLocate()", locationEffects);
        }
        // longAction
        else if (act.getFunctor().equals("longAction")) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {}
        } // connect
        else if (act.getFunctor().equals("connect")) {
            retval = a_connect(ag);
        }
        else if (act.getFunctor().equals("returning")) {
            retval = true;
            removePerceptsByUnif(ag, Literal.parseLiteral("reason(X)"));
            addPercept(ag, Literal.parseLiteral("reason(pes)"));
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
