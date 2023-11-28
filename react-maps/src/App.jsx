import React, { useState, useEffect } from "react";
import "./App.css";
import Map1 from "./Maps1.jsx";
import RestaurantList from "./RestaurantList.jsx";
import { useLocation } from "react-router-dom";


// Austurvöllur square in Reykjavik

// Rua perobas n 415 bairro colonial contagem
// Avenida vila rica n 1150 bairro inconfidentes
// Rua domingos silva guimarães 331 bairro industrial
// Rua carlos chagas 652 industrial




const restauranteListrs = [

]

function useQuery() {
  const { search } = useLocation();


  return React.useMemo(() => new URLSearchParams(search), [search]);
}
function App() {
  let query = useQuery();

  const [restaurantPosition, setRestaurantPosition] = useState(null);
  const [restaurantList, setResaturantList] = useState(restauranteListrs);
  const [userPosition, setUserPosition] = useState(null);

  useEffect(() => {
    if(query.get("latitude") && query.get("longitude")){
      setUserPosition({ lat: query.get("latitude"), lng: query.get("longitude") })
    } else {
      navigator.geolocation.getCurrentPosition((position) => {
        const { latitude, longitude } = position.coords;
        
        console.log(latitude, longitude);
        setUserPosition({ lat: latitude, lng: longitude });
      });
    }

  

    const getLocalStorage = () => {
      const data =  localStorage.getItem('city')
      if(data){
        return JSON.parse(data)
      }else{
        return []
      }
    }
    const listInput = getLocalStorage()    

    setResaturantList(listInput);
  }, []);


  const onClickHandler_ = (location) => {
    setRestaurantPosition(location);
  };
  return (
    <div className="App">
      <div>
        {userPosition !== null ? <div>
          <Map1 apikey={"B-HjDu6XumF51KPc6A2aS6hDHDjSbfhWxSVXbdih3hQ"}
          userPosition={userPosition}
          restaurantPosition={restaurantPosition}
          list={restaurantList}
           />
        </div> : <h1>loading </h1>}

        <RestaurantList list={restaurantList} onClickHandler={onClickHandler_} />
      </div>
    </div>
  );
}

export default App;
