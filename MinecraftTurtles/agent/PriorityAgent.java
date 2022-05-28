package agent;

import jason.asSemantics.Agent;
import jason.asSemantics.Intention;
import jason.asSemantics.IntendedMeans;
import jason.asSemantics.Unifier;
import jason.asSyntax.Trigger;
import jason.asSyntax.Plan;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;


import java.util.Iterator;
import java.util.Queue;

/**
 * change the default select event function to prefer cell(_,_,gold) events.
 *
 * @author Jomi
 */
public class PriorityAgent extends Agent {
    public Intention selectIntention(Queue<Intention> intentions) {
        Iterator<Intention> iIntentions = intentions.iterator();
        // System.out.println("III ss: " + intentions.size());
        float highest = 0;
        while (iIntentions.hasNext()) {
            Intention intention = iIntentions.next();
            float prio = getIntentionPriority(intention);
            if (prio > highest) highest = prio;
        }
        
        if (highest == 0) return null;
        
        iIntentions = intentions.iterator();
        while (iIntentions.hasNext()) {
            Intention intention = iIntentions.next();
            float prio = getIntentionPriority(intention);
            if (prio == highest)  {
                iIntentions.remove();
                System.out.println("III Selected: " + intention);
                return intention;   
            }
        }
        return super.selectIntention(intentions);
    }
    
    private float getMeansPriority(IntendedMeans means) {
        Plan plan = means.getPlan();
        Literal priorityLiteral = plan.getLabel().getAnnot("priority");
        
        if (priorityLiteral != null) {
            Term pterm = priorityLiteral.getTerm(0);
            if (pterm.isNumeric()) {
                return Float.parseFloat(pterm.toString());
            }
        }
        return 0;
    }
    
    private float getIntentionPriority(Intention intention) {
        Iterator<IntendedMeans> iMeans = intention.iterator();
        float highest = 0;
        while (iMeans.hasNext()) {
            IntendedMeans means = iMeans.next();
            float prio = getMeansPriority(means);
            if (prio > highest) highest = prio;
        }
        return highest;
    }
}
