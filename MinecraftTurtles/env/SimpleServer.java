package env;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.lang.Thread;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;



public class SimpleServer extends WebSocketServer {
    HashMap<String, LinkedBlockingQueue<String>> newPcQueues;
    HashMap<String, BlockingQueue<JSONObject>> pcQueues;
    HashMap<String, WebSocket> pc2conn;

    public SimpleServer(InetSocketAddress address, HashMap<String, LinkedBlockingQueue<String>> _newPcQueues) {
        super(address);
        newPcQueues = _newPcQueues;
        pcQueues = new HashMap<>();
        pc2conn = new HashMap<String, WebSocket>();
    }


    public boolean exec(String pc, JSONObject json) {
        WebSocket conn = pc2conn.get(pc);
        conn.send(json.toString());
        return true;
    }

    public boolean acceptConnection(String ag, String pc, BlockingQueue<JSONObject> queue) {
        pcQueues.put(pc, queue);
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {}
        pc2conn.get(pc).send("Connected as " + ag + ".");
        
        return true;
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        String pc = conn.getRemoteSocketAddress().toString();
        String channel = "0";
        if (handshake.hasFieldValue("turtlechannel")) {
            channel = handshake.getFieldValue("turtlechannel");
        }
        System.out.println("-- new connection to " + pc + " on channel " + channel);
        if (!newPcQueues.containsKey(channel)) {
            conn.send("Unknown channel: "+channel);
            return;
        }

        pc2conn.put(pc, conn);
        try {
            newPcQueues.get(channel).put(pc);
        } catch (InterruptedException e) { return; }
        conn.send("Acknowledged.");
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("closed " + conn.getRemoteSocketAddress() + " with exit code " + code + " additional info: " + reason);
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        // System.out.println("received message from "    + conn.getRemoteSocketAddress() + ": " + message);
        String pc = conn.getRemoteSocketAddress().toString();
        JSONObject obj = new JSONObject(message);
        try {
            pcQueues.get(pc).put(obj);
        } catch (InterruptedException e) { return; }
    }

    @Override
    public void onMessage( WebSocket conn, ByteBuffer message ) {
        System.out.println("received ByteBuffer from "    + conn.getRemoteSocketAddress());
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        if (conn == null) {
            System.err.println("--\nWebSocket server Error:\n  " + ex + "\n--");
        } else {
            System.err.println("an error occurred on connection "  + conn.getRemoteSocketAddress() + ":" + ex);
        }
    }

    @Override
    public void onStart() {
        System.out.println("server started successfully");
    }


    public static void main(String[] args) {

    }
}
