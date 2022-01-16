module source.cruisetype;

import source.cruise;
import source.city;
import std.datetime.date;
import std.stdio;
import std.conv;
import std.json;
import core.time : Duration;
import std.random;

enum Type {
    EXPRESS,
    PASSANGER
}

class CruiseType : Cruise
{
    private Type type;
    private Date arrivalDate;
    private City[] interStops;
    private int position;

    this(string fromCity, string toCity, Type type, Date startDate, Date arrivalDate, int distance) {
        super(fromCity, toCity, startDate, distance);
        this.type = type;
        this.arrivalDate = arrivalDate;
        this.position = -1;
    }

    void addIntermediateStop(string city, Date date) {
        interStops ~= new City(city, date);

        regenerateDistances(0);
    }

    void regenerateDistances(int adjust) {
        for (int i = 0; i < interStops.length; ++i) {
            if (i == position) {
                interStops[i].distance = 0;
                continue;
            }

            int initialDistance = distance / ((cast(int)interStops.length + 1) + adjust);
            int randomDistance = 0;

            if (i % 2 == 0) {
                randomDistance = initialDistance + rndGen().front() % 100;
                rndGen().popFront();
            }
            else {
                randomDistance = initialDistance - rndGen().front % 100;
                rndGen().popFront();
            }

            if (i == 0) {
                interStops[i].distance = randomDistance;
            } 
            else {
                int totalDistance = randomDistance;
                for (int j = 0; j < interStops.length; ++j) {
                    totalDistance += interStops[j].distance;
                }
                interStops[i].distance = totalDistance;
            }
        }
    }

    City[] getIntermediateStops() {
        return interStops;
    }

    override string toJson() {
        auto data = "{ \"id\": " ~ to!string(getId()) ~ ", " 
            ~ "\"type\": \"" ~ to!string(type) 
            ~ "\", \"from\": \"" ~ fromCity 
            ~ "\", \"to\": \"" ~ toCity 
            ~ "\", \"start_date\": \"" ~ startDate.toISOExtString() 
            ~ "\", \"arrival_date\": \"" ~ arrivalDate.toISOExtString() 
            ~ "\", \"distance\": " ~ to!string(getDistance()) 
            ~ ", \"travel_time\": " ~ to!string(getTravelTime())
            ~ ", \"avg_speed\": " ~ to!string(getAvgSpeed())
            ~ ", \"intermediate_stops\": ["; 

        for (int i = 0; i < interStops.length; ++i) {
            data ~= "{ \"city\": \"" ~ interStops[i].name ~ "\", \"distance\": " ~ to!string(interStops[i].distance) ~ ", \"date\": \"" ~ interStops[i].arrivalDate.toISOExtString() ~ "\" } ";
            if (i != interStops.length - 1) {
                data ~= ", ";
            }
        }

        data ~= "] }";

        return data;
    }

    override void print() {
        writeln(this.toJson());
    }

    long getTravelTime() {
        Duration time = position == -1
            ? cast(Date) arrivalDate - startDate
            : cast(Date) arrivalDate - interStops[position].arrivalDate;

        if (againstTheCurrent) {
            return time.total!"days" + 2; 
        }
        else {
            return time.total!"days";
        }
    }

    float getAvgSpeed() {
        return getDistance() / getTravelTime();
    }

    void advancePosition() {
        if (position < interStops.length + 1) {
            this.position += 1;
            writeln("pos", position);

            regenerateDistances(position);
        }
    }

    int getPosition() {
        return position;
    }

    int getDistance() {
        if (position == -1) {
            return distance;
        }
        
        if (position == interStops.length) {
            return 0;
        }

        int coveredDistance = 0;
        for (int i = position; i < interStops.length; ++i) {
            coveredDistance += interStops[i].distance;
        }

        return distance - coveredDistance;
    }

    string getDateOfArrival(string city) {
        if (city == fromCity) {
            return startDate.toISOExtString();
        }

        foreach (City key; interStops) {
            if (key.name == city) {
                return key.arrivalDate.toISOExtString();
            }
        }

        return arrivalDate.toISOExtString();        
    }

    int getDistanceBetweenStartAnd(string city) {
        if (city == toCity) {
            return distance;
        }

        foreach (City key; interStops) {
            if (key.name == city) {
                return key.distance;
            }
        }

        return 0;
    }

    long getTravelTimeTo(string city) {
        if (city == toCity) {
            return getTravelTime();
        }

        foreach (City key; interStops) {
            if (key.name == city) {
                Duration time = cast(Date)key.arrivalDate - startDate;
                return time.total!"days";
            }
        }

        return 0;
    }

    Type getType() {
        return type;
    }
}