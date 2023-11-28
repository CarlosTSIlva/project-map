import React from 'react';

const RestaurantEntry = (props) => {
    const handleClick = () => {
      props.onClickHandler(props.data.location);
    };
    // Add basic styling for each restaurant entry
    const entryStyle = {
      display: "inline-block",
      padding: "10px",
      margin: "5px",
      border: "1px solid gray",
      borderRadius: "5px",
      cursor: "pointer",
    };
  
    return (
      <div style={entryStyle} onClick={handleClick}>
        {props.data.name}
      </div>
    );
  }
  
  const goToRoute = (lat) => {
    console.log()
    console.log(lat.location.lng)

    const myLocation = JSON.parse(localStorage.getItem('myLocation'));
    console.log(myLocation)

    // open to google maps
    const linkGoogleMaps = `https://www.google.com/maps/dir/?api=1&origin=${myLocation.lat},${myLocation.lng}&destination=${lat.location.lat},${lat.location.lng}&travelmode=driving`
    // open link
    window.open(linkGoogleMaps, '_blank');
    console.log(linkGoogleMaps)
  }
  function RestaurantList(props) {
    const entries = props.list;
    const list = entries.map((entry) => {
      return <div style={{display: "flex", flexDirection:"row"}}> <RestaurantEntry data={entry} onClickHandler={props.onClickHandler} ></RestaurantEntry> <button style={{marginTop: "8px", marginBottom: "8px"}} onClick={() => goToRoute(entry)} >Ir para rota</button></div>
    });
    return (
      <div id="restaurant-list" style={ {'display': 'grid'} } >
      {list}
      </div>
    )
  }
  
  export default RestaurantList;
