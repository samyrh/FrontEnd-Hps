// src/routes/AppRoutes.jsx
import { Routes, Route, Navigate } from 'react-router-dom';
import Cards from '../layers/Cards';
import Users from '../layers/Users';
import UsersDetails from '../layers/UsersDetails';
import MainDashboard from '../layers/MainDashboard';
import TravelPlan from '../layers/TravelPlan';
import AgentProfile from '../layers/AgentProfile';
import CardsDetails from '../layers/CardsDetails'; // ✅ Add this

export default function AppRoutes() {
    return (
        <Routes>
            <Route path="/" element={<MainDashboard />} />
            <Route path="/cards" element={<Cards />} />
            <Route path="/card-details" element={<CardsDetails />} /> {/* ✅ New route */}
            <Route path="/users" element={<Users />} />
            <Route path="/users/details" element={<UsersDetails />} />
            <Route path="/travel" element={<TravelPlan />} />
            <Route path="/profile" element={<AgentProfile />} />
            <Route path="*" element={<Navigate to="/" />} />
        </Routes>
    );
}
