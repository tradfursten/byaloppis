// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

Hooks.Map = {
  mounted() {
    const pushEventToComponent = (event, payload) => {
      this.pushEventTo(this.el, event, payload);
    };

    mapboxgl.accessToken = window.mapboxAccessToken
    var map = new mapboxgl.Map({
      container: "map",
      style: 'mapbox://styles/mapbox/streets-v11',
      zoom: 14,
      maxZoom: 17,
      center: [20.252, 63.824]
    });

    var marker = null;

    var markers = [];

    map.on("load", () => {
      map.addSource("location", {
        "type": "geojson",
        "data": {
          "type": "Point",
          "coordinates": [20.252, 63.824]
        }
      })

      map.addLayer({
        'id': 'location',
        'type': 'circle',
        'source': 'location',
        'paint': {
          'circle-radius': 5,
          'circle-color': '#007cbf'
        }
      })
      map.resize();
    })

    this.handleEvent("position", (coords) => {
      map.flyTo({
        center: [
          coords.lng,
          coords.lat
        ],
        zoom: 14
      }, { animate: false })
      if (marker !== null) {
        marker.remove()
      }
      marker = new mapboxgl.Marker({draggable: true})
        .setLngLat([coords.lng, coords.lat])
        .addTo(map);

      function onDragEnd() {
        const lngLat = marker.getLngLat();
        pushEventToComponent('set_lat_lng', { lat: lngLat.lat, lng: lngLat.lng });
      }
           
      marker.on('dragend', onDragEnd);
    })

    this.handleEvent("marker", (coords) => {
       markers.push(new mapboxgl.Marker()
        .setLngLat([coords.lng, coords.lat])
        .addTo(map));
    })

    this.handleEvent("list_tables", (e) => {
      console.log(e)
      markers = [];
      e.tables.forEach(it => {
        const popup = new mapboxgl
          .Popup({ offset: 25 })
          .setHTML(`<a href='/tables/${it.id}' 
            class='text-[0.8125rem] font-semibold leading-6 text-zinc-900 hover:text-zinc-700' 
            onclick='liveSocket.redirect("/tables/${it.id}"); return false;'>
          ${it.address}
          </a>`);
        markers.push(new mapboxgl.Marker()
        .setLngLat([it.lng, it.lat])
        .setPopup(popup)
        .addTo(map));
      });
      const bounds = new mapboxgl.LngLatBounds();

      markers.forEach(it => {
          bounds.extend(it.getLngLat());
      });
      
      map.fitBounds(bounds, { padding: 30, animate: false });
      
    });
  }
}

Hooks.LocalTime = {
  mounted(){
    this.updated()
  },
  updated() {
    console.log(this.el.textContent)
    let dt = new Date(this.el.textContent);
    this.el.textContent = dt.toLocaleString()
  }
}


let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

