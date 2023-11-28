
import React, { useEffect, useState } from 'react';
import { usePlacesWidget } from "react-google-autocomplete";
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Modal from '@mui/material/Modal';

const style = {
  position: 'absolute',
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: "100%",
  bgcolor: 'background.paper',
  border: '2px solid #000',
  boxShadow: 24,
  p: 4,
};
import { useNavigate, useLocation } from "react-router-dom";
import {
  setDefaults,
  geocode,
  RequestType,
} from "react-geocode";
const google_api = "AIzaSyCBy9mMdcref4d5SslIbD8RJ0L6iiWQGZY" // Your API key here.

setDefaults({
  key: google_api,
  language: "pt",
  region: "br",
});
import { useSpeechRecognition } from 'react-speech-kit';


function useQuery() {
  const { search } = useLocation();


  return React.useMemo(() => new URLSearchParams(search), [search]);
}
function App2() {
  const navigate = useNavigate();

  const [listString, setListString] = useState([])
  const [myLocation, setMyLocation] = useState({})
  let query = useQuery();

  const { ref } = usePlacesWidget({
    options: { types: ['address'] },
    apiKey: google_api,
    language: 'pt-BR',
    onPlaceSelected: (place) => {
      console.log(place)
      const value = place.formatted_address;
      setString1(value)

    },

  })

  const [open, setOpen] = React.useState(false);
  const [string1, setString1] = useState("")

  const handleOpen = () => setOpen(true);
  const handleClose = () => setOpen(false);
  const handlAddString = () => {
    setListString([...listString, string1])
    setString1("")
  };

  const { listen, listening, stop } = useSpeechRecognition({
    onResult: (result) => {
      setString1(result)
    },

  });



  const handleListenAll = () => {
    if (listening) {
      stop()
      // delay in 1 seconds

      handleClose()
      setTimeout(() => {
        console.log("foi")
        document.getElementById("inputAutoComplete").focus();
      }, 1000)
      return;
    }
    listen({ lang: 'pt-BR' });
  };


  useEffect(() => {
    if (query.get("latitude") && query.get("longitude")) {
      setMyLocation({ lat: query.get("latitude"), lng: query.get("longitude") })
    } else {
      navigator.geolocation.getCurrentPosition((position) => {
        const { latitude, longitude } = position.coords;
        console.log(latitude, longitude);
        setMyLocation({ lat: latitude, lng: longitude })
      })
    }
  }, [])

  return (
    <div className="App">
      <div style={{
        display: 'flex',
        flexDirection: 'column',
      }}>
        <div>
          <Button style={{
            fontSize: 21,
          }} onClick={handlAddString}>Adicionar</Button>
          <Button style={{
            fontSize: 21,
          }} onClick={handleOpen}>Audio</Button>
          <Button style={{
            fontSize: 21,
          }} onClick={async () => {
            let arrList = []
            listString.forEach((item) => {
              geocode(RequestType.ADDRESS, item)
                .then(({ results }) => {
                  const { lat, lng } = results[0].geometry.location;
                  const to = {
                    lat,
                    lng,
                  }

                  function calculateDistance(lat1, lon1, lat2, lon2) {
                    const R = 6371e3; // radius of Earth in metres
                    const φ1 = lat1 * Math.PI / 180; // φ, λ in radians
                    const φ2 = lat2 * Math.PI / 180;
                    const Δφ = (lat2 - lat1) * Math.PI / 180;
                    const Δλ = (lon2 - lon1) * Math.PI / 180;

                    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
                      Math.cos(φ1) * Math.cos(φ2) *
                      Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
                    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

                    const distance = R * c; // in metres
                    return distance;
                  }
                  arrList.push({ location: { lat, lng, }, name: item, distance: calculateDistance(myLocation.lat, myLocation.lng, to.lat, to.lng) })

                  localStorage.setItem('city', JSON.stringify(arrList));
                  console.log("", arrList.length)
                })
                .catch(console.error).finally(() => {
                  console.log("finalizou")
                })
            })
            // delay to 4 seconds
            await new Promise(resolve => setTimeout(resolve, 4000));
            arrList.sort((a, b) => a.distance - b.distance)


            // set local storage
            localStorage.setItem('city', JSON.stringify(arrList));
            localStorage.setItem('myLocation', JSON.stringify(myLocation));
            var route;
            if (query.get("latitude") && query.get("longitude")) {
              route = "/route?latitude=" + query.get("latitude") + "&longitude=" + query.get("longitude");
            }
            else {
              // navigator to routes
              route = "/route?latitude=" + myLocation.lat + "&longitude=" + myLocation.lng;
            }

            navigate(route)

          }
          }>Criar rota</Button>
        </div>
        <input style={{ width: "100%", height: 40 }} id="inputAutoComplete" onChange={(e) => {
          setString1(e.target.value)
        }} value={string1} ref={ref} />
      </div>


      <Modal
        open={open}
        onClose={handleClose}
        aria-labelledby="modal-modal-title"
        aria-describedby="modal-modal-description"
      >
        <Box sx={style}>

          <Button onClick={handleListenAll}>{!listening ? " Gravar audio " : "parar"}</Button>

        </Box>
      </Modal>
      {listString.map((item, index) => { return <p key={item}>{item}</p> })}

    </div>
  );
}

export default App2;
