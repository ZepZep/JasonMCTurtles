package env;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.concurrent.BlockingQueue;


public class SimpleServer extends WebSocketServer {
    BlockingQueue<String> newPcQueue;
    HashMap<String, BlockingQueue<JSONObject>> pcQueues;
    HashMap<String, WebSocket> pc2conn;

    public SimpleServer(InetSocketAddress address, BlockingQueue<String> _newPcQueue) {
        super(address);
        newPcQueue = _newPcQueue;
        pcQueues = new HashMap<>();
        pc2conn = new HashMap<String, WebSocket>();
    }


    public boolean execs(String ag, JSONObject json) {
        json.put("ag", ag);
        broadcast(json.toString());
        return true;
    }

    public boolean acceptConnection(String ag, String pc, BlockingQueue<JSONObject> queue) {
        pcQueues.put(pc, queue);
        // System.out.println(ag + " " + pc);
        pc2conn.get(pc).send("Connected as " + ag + ".");
        return true;
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        System.out.println("-- new connection to " + conn.getRemoteSocketAddress());
        String pc = conn.getRemoteSocketAddress().toString();
        try {
            newPcQueue.put(pc);
        } catch (InterruptedException e) { return; }

        pc2conn.put(pc, conn);
        conn.send("Acknowledged.");
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("closed " + conn.getRemoteSocketAddress() + " with exit code " + code + " additional info: " + reason);
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        System.out.println("received message from "    + conn.getRemoteSocketAddress() + ": " + message);
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
