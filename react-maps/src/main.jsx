import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import App2 from "./orderby/App2"
import './index.css'


import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom";


const router = createBrowserRouter([
  {
    path: "/route",
    element: <App />,
  }, 
  {
    path: "/",
    element: <App2 />,
  }, 
]);
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
)
