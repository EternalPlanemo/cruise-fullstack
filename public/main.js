$(function() {
    window.socket = new WebSocket(getBaseURL() + "/api");
    window.socket.onopen = function() {
        console.log("establishing connection...");

        setTimeout(() => {
            socket.send(JSON.stringify({ rpc: 'show-all' }));
        }, 200);
    }
    window.socket.onmessage = function(message) {	
        const res = JSON.parse(message.data);
        const $tbody = $('.form__body table tbody');
        $tbody.empty();

        const render = (cruise) => {
            let intermediateStopsHtml = '<div class="stops">'
                cruise.intermediate_stops.forEach((stop, index) => {
                    let stopHtml = `
                            ${index === 0 ? '<h2 class="stops__title">Intermediate Stops</h2>' : ''}

                            <div class="stop">
                                <div class="stop__city">
                                    ${index === 0 ? '<h4>City</h4>' : ''}

                                    <div>
                                        ${stop.city}
                                    </div>
                                </div>

                                <div class="stop__distance">
                                    ${index === 0 ? '<h4>Distance</h4>' : ''}
                                    
                                    <div>
                                        ${stop.distance}km
                                    </div>
                                </div>

                                <div class="stop__date">
                                    ${index === 0 ? '<h4>Arrival Date</h4>' : ''}

                                    <div>
                                        ${stop.date}
                                    </div>
                                </div>
                            </div>
                    `;

                    intermediateStopsHtml = intermediateStopsHtml + stopHtml;
                });

                intermediateStopsHtml = intermediateStopsHtml + '</div>';

                // console.log(intermediateStopsHtml);

            $tbody.append(`
                <tr class="primary ${cruise.intermediate_stops.length !== 0 ? 'has-stops' : ''}">
                    <td>
                        ${cruise.id}
                    </td>
                    
                    <td>
                        ${cruise.type}
                    </td>

                    <td>
                        ${cruise.from}
                    </td>

                    <td>
                        ${cruise.to}
                    </td>

                    <td>
                        ${cruise.start_date}
                    </td>

                    <td>
                        ${cruise.arrival_date}
                    </td>

                    <td>
                        ${cruise.distance}km
                    </td>

                    <td>
                        ${cruise.travel_time} days
                    </td>

                    <td>
                        ${cruise.avg_speed}km/h
                    </td>
                </tr>

                <tr style="display: none;">
                    <td colspan="9">
                        ${intermediateStopsHtml}
                    </td>
                </tr>
            `);
        }

        if (Array.isArray(res)) {
            res.forEach(cruise => {
                render(cruise);
            });
        }
        else {
            render(res);
        }
    }
    window.socket.onclose = function() {
        console.log("connection closed");
    }
    window.socket.onerror = function() {
        console.log("error");
    }

    function getBaseURL()
    {
        return "ws://" + window.location.host;
    }

    $('.nav .btn').on('click', function(e) {
        e.preventDefault();
        const inner = e.target.innerHTML;
        const rpcName = inner.toLowerCase().replace(/\s/g, '-');

        $('.form__head').children().first().html(inner);

        if (rpcName == 'all-cruises') {
            $('.modal').slideUp();
            window.socket.send(JSON.stringify({ rpc: 'show-all' }));
            return;
        }

        const modalMap = {
            'search-course': SearchByCourse(),
            'search-by-start-date': SearchByStartDate(),
            'search-by-arrival-date': SearchByArrivalDate(),
            'find-fastest': FindFastest(),
            'average-speed-by-type': AverageSpeedByType()
        };

        $('.form__controls').empty().append(modalMap[rpcName]);
        $('.modal').slideDown();
    });

    $('tbody').on('click', 'tr.primary.has-stops', function(e) {
        $(this).next().toggle();
    });

    $('form').submit(function(e) {
        e.preventDefault();
    });
});

const Modal = ({ children, title, rpc }) => {
    window.Modal = {};
    window.Modal.handleClick = (event) => {
        event.preventDefault();
        const data = new FormData($('.modal').get(0));
        const jsonData = {};

        data.forEach((value, key) => {
            jsonData[key] = value;
        });

        window.socket.send(JSON.stringify({
            rpc: rpc,
            input: JSON.stringify(jsonData)
        }));

        $('.modal').slideUp();
    }

    return `
        <form class="modal">
            <div class="modal__head">
                <h2 class="title">${title}</h2>
            </div>

            <div class="modal__body">
                ${children}
            </div>

            <div class="modal__controls">
                <button class="btn" onclick="window.Modal.handleClick(event)">Submit</button>
            </div>
        </form>
    `
}

const SearchByCourse = () => {
    return Modal({
        title: 'Search by Course',
        rpc: 'search-by-course',
        children: `
            <div class="form__row">
                <label for="from-city">From:</label>

                <input type="text" name="from-city" id="from-city">
            </div>

            <div class="form__row">
                <label for="to-city">To:</label>

                <input type="text" name="to-city" id="to-city">
            </div>
        `
    });    
}

const SearchByStartDate = () => {
    return Modal({
        title: 'Search by Start Date',
        rpc: 'search-by-start-date',
        children: `
            <div class="form__row">
                <label for="from-city">From:</label>

                <input type="text" name="from-city" id="from-city">
            </div>

            <div class="form__row">
                <label for="to-city">To:</label>

                <input type="text" name="to-city" id="to-city">
            </div>

            <div class="form__row">
                <label for="date">Date:</label>

                <input type="date" name="date" id="date">
            </div>
        `
    });    
}

const SearchByArrivalDate = () => {
    return Modal({
        title: 'Search by Arrival Date',
        rpc: 'search-by-arrival-date',
        children: `
            <div class="form__row">
                <label for="from-city">From:</label>

                <input type="text" name="from-city" id="from-city">
            </div>

            <div class="form__row">
                <label for="to-city">To:</label>

                <input type="text" name="to-city" id="to-city">
            </div>

            <div class="form__row">
                <label for="date">Date:</label>

                <input type="date" name="date" id="date">
            </div>
        `
    });    
}

const FindFastest = () => {
    return Modal({
        title: 'Find Fastest',
        rpc: 'find-fastest',
        children: `
            <div class="form__row">
                <label for="from-city">From:</label>

                <input type="text" name="from-city" id="from-city">
            </div>

            <div class="form__row">
                <label for="to-city">To:</label>

                <input type="text" name="to-city" id="to-city">
            </div>
        `
    });    
}

const AverageSpeedByType = () => {
    return Modal({
        title: 'Find Fastest',
        rpc: 'average-speed-by-type',
        children: `
            <div class="form__row">
                <label for="type">Type:</label>

                <select name="type" id="type">
                    <option value="PASSANGER">PASSANGER</option>
                    <option value="EXPRESS">EXPRESS</option>
                </select>
            </div>
        `
    });    
}