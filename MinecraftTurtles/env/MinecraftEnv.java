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

    boolean a_execs(String ag, String action) {
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

        System.out.println(obj.toString());


        return true;
    }

    boolean execAndLocate(String ag, String action) {
        JSONObject json = new JSONObject();
        json.put("func", "return " + "a");
        json.put("locate", "true");

        server.exec(ag, json);
        return true;
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
                retval = a_execs(ag, literal);
            } else {
                retval = a_exec(ag, literal);
            }
        } // longAction
        else if (act.getFunctor().equals("longAction")) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {}
        } // connect
        else if (act.getFunctor().equals("connect")) {
            retval = a_connect(ag);
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
