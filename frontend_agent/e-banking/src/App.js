// src/App.js
import React from 'react';
import MainDashboard from './layers/MainDashboard';
import Users from "./layers/Users";
import Cards from "./layers/Cards";
import CardsDetails from "./layers/CardsDetails";
import TravelPlan from "./layers/TravelPlan";
import AgentProfile from "./layers/AgentProfile";
import AppRoutes from "./Routes/Routes";

function App() {
    return <AppRoutes />;
}

export default App;
