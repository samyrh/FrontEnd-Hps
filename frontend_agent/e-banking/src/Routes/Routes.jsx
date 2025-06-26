// src/routes/AppRoutes.jsx
import { Routes, Route } from 'react-router-dom';
import Cards from '../layers/Cards';
import CardsDetails from '../layers/CardsDetails';
import MainDashboard from '../layers/MainDashboard';
import Users from '../layers/Users';
import TravelPlan from '../layers/TravelPlan';
import AgentProfile from '../layers/AgentProfile';



export default function AppRoutes() {
    return (
        <Routes>
            <Route path="/" element={<MainDashboard />} /> {/* Main Dashboard */}
            <Route path="/cards" element={<Cards />} />
            <Route path="/card-details/:id" element={<CardsDetails />} />
            <Route path="/users" element={<Users />} />
            <Route path="/travel-plan" element={<TravelPlan />} />
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/profile" element={<AgentProfile />} />
            <Route path="/signin" element={<SignIn />} />
        </Routes>
    );
}
