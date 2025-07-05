// src/routes/AppRoutes.jsx
import { Routes, Route, Navigate } from 'react-router-dom';
import Cards from '../layers/Cards';
import Users from '../layers/Users';
import UsersDetails from '../layers/UsersDetails';
import MainDashboard from '../layers/MainDashboard';
import TravelPlan from '../layers/TravelPlan';
import AgentProfile from '../layers/AgentProfile';
import CardsDetails from '../layers/CardsDetails';
import Notifications from "../layers/Notifications";
import Transactions from "../layers/Transactions";



export default function AppRoutes() {
    return (
        <Routes>
            <Route path="/" element={<MainDashboard />} />
            <Route path="/cards" element={<Cards />} />
            <Route path="/card-details" element={<CardsDetails />} />
            <Route path="/users" element={<Users />} />
            <Route path="/users/details" element={<UsersDetails />} />
            <Route path="/travel" element={<TravelPlan />} />
            <Route path="/profile" element={<AgentProfile />} />
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/transactions" element={<Transactions />} />
            <Route path="*" element={<Navigate to="/" />} />
        </Routes>
    );
}
