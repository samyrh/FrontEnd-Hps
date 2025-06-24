import { Routes, Route, Navigate } from 'react-router-dom';
import Cards from '../pages/Cards';
import CardsDetails from '../pages/CardsDetails'; // ✅ Ensure this is correct
import Home from '../pages/Home';

export default function AppRoutes() {
    return (
        <Routes>
            <Route path="/" element={<Navigate to="/cards" />} />
            <Route path="/cards" element={<Cards />} />
            <Route path="/card-details/:id" element={<CardsDetails />} /> {/* ✅ This is what your CardTable needs */}
            <Route path="/home" element={<Home />} />
        </Routes>
    );
}
