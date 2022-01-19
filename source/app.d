module source.main;

import source.cruisetype : CruiseType, Type;
import source.cruisenetwork;
import std.datetime.date : Date;
import std.random;
import std.stdio;
import vibe.d;
import std.file;
import vibe.core.core : sleep;
import vibe.core.log;
import vibe.http.fileserver : serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server;
import vibe.http.websockets : WebSocket, handleWebSockets;
import std.conv;
import std.json;

void main(string[] args)
{
    auto ct0 = new CruiseType("Bucharest", "Vienna", Type.PASSANGER, Date(2021, 11, 16), Date(2021, 12, 18), 1000);
    ct0.addIntermediateStop("Belgrade", Date(2021, 11, 29));
    ct0.addIntermediateStop("Komarno", Date(2021, 12, 4));

    auto ct1 = new CruiseType("Bucharest", "Kulcs", Type.EXPRESS, Date(2022, 1, 12), Date(2022, 2, 28), 700);

    auto ct2 = new CruiseType("Bucharest", "Budapest", Type.PASSANGER, Date(2022, 2, 4), Date(2022, 2, 20), 950);
    ct2.addIntermediateStop("Tarnovo", Date(22, 2, 5));
    ct2.addIntermediateStop("Vidin", Date(22, 2, 6));
    ct2.addIntermediateStop("Belgrade", Date(22, 2, 10));

    auto ct3 = new CruiseType("Osijek", "Budapest", Type.EXPRESS, Date(2022, 2, 11), Date(2022, 2, 18), 640);
    ct3.addIntermediateStop("Kalocsa", Date(22, 2, 13));

    CruiseType[] cruises;
    cruises ~= ct0;
    cruises ~= ct1;
    cruises ~= ct2;
    cruises ~= ct3;
    auto cn = new CruiseNetwork(cruises);

    auto router = new URLRouter;

    router.get("*", serveStaticFiles("public/"));

    router.get("/css", function(HTTPServerRequest req, HTTPServerResponse res) {
        auto css = readText(format("public/% s", req.params ["f"]));
        res.writeBody(css, "text/css");
    });

    router.get("/js", function(HTTPServerRequest req, HTTPServerResponse res) {
        auto js = readText(format("public/% s", req.params ["f"]));
        res.writeBody(js, "text/javascript");
    });

    router.get("/images", function(HTTPServerRequest req, HTTPServerResponse res) {
        auto image = readText(format("public/images/% s", req.params ["f"]));
        res.writeBody(image);
    });

    router.get("/search", function(HTTPServerRequest req, HTTPServerResponse res) {
        auto html = readText(format("public/search.html"));
        res.writeBody(html, "text/html");
    });



    router.get("/api", handleWebSockets(delegate(scope WebSocket socket) {
        while (true) {
            sleep(1.seconds);
            if (!socket.connected) break;
            auto json = parseJsonString(socket.receiveText());
            auto rpc = json["rpc"];

            writeln("rpc " ~ rpc);

            if (rpc == "show-all") {
                string result = "[ ";

                for (int i = 0; i < cruises.length; ++i) {
                    result ~= cruises[i].toJson();

                    if (i != cruises.length - 1) {
                        result ~= ", ";
                    }
                }

                result ~= " ]";

                socket.send(result);
            }
            else if (rpc == "search-by-course") {
                auto input = parseJsonString(json["input"].to!string);
                auto fromCity = input["from-city"].to!string;
                auto toCity = input["to-city"].to!string;
                auto res = cn.getCruisesFromTo(fromCity, toCity);

                socket.send(res);
            }
            else if (rpc == "search-by-start-date") {
                auto input = parseJsonString(json["input"].to!string);
                auto fromCity = input["from-city"].to!string;
               auto toCity = input["to-city"].to!string;
                auto date = input["date"].to!string;

                auto res = cn.getCruisesBeforeStartDate(fromCity, toCity, date);

                socket.send(res);
            }
            else if (rpc == "search-by-arrival-date") {
                auto input = parseJsonString(json["input"].to!string);
                auto fromCity = input["from-city"].to!string;
                auto toCity = input["to-city"].to!string;
                auto date = input["date"].to!string;

                auto res = cn.getCruisesBeforeArrivalDate(fromCity, toCity, date);

                socket.send(res);
            }   
            else if (rpc == "find-fastest") {
                auto input = parseJsonString(json["input"].to!string);
                auto fromCity = input["from-city"].to!string;
                auto toCity = input["to-city"].to!string;
                auto res = cn.getFastestCruise(fromCity, toCity);

                socket.send(res);
            }
            else if (rpc == "average-speed-by-type") {
                auto input = parseJsonString(json["input"].to!string);
                auto type = input["type"].to!string;
                auto res = cn.getAvgSpeedByType(type);

                socket.send(res);
            }
        }
    }));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    listenHTTP(settings, router);
    runApplication();
}