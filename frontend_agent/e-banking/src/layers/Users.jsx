// src/pages/Users.jsx
import React, { useState, useRef, useEffect } from 'react';
import {
    Box,
    useColorModeValue,
    Collapse,
} from '@chakra-ui/react';

import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import StatisticCards from '../component/StatisticCards';
import UsersTable from '../component/UsersTable';
import PersonalInfos from '../component/PersonalInfos';
import Popup from '../component/Popup';

export default function Users() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');
    const [showForm, setShowForm] = useState(false);
    const [showPopup, setShowPopup] = useState(false);
    const formRef = useRef(null);
    const popupTimerRef = useRef(null);

    const scrollToForm = () => {
        setTimeout(() => {
            if (formRef.current) {
                formRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }, 300); // wait for Collapse animation
    };

    const handleAddUserClick = () => {
        setShowForm(true);
        setShowPopup(false);
        clearTimeout(popupTimerRef.current);
        scrollToForm();
    };

    const handlePartialInput = (filledCount) => {
        clearTimeout(popupTimerRef.current);

        if (filledCount > 0 && filledCount < 3) {
            popupTimerRef.current = setTimeout(() => {
                setShowPopup(true);
            }, 60000); // ⏱️ 1 minute
        } else {
            setShowPopup(false);
        }
    };

    const handleFormTimeout = () => {
        setShowForm(false);
        setShowPopup(false);
        clearTimeout(popupTimerRef.current);
    };

    return (
        <Box minH="100vh" bg={bg}>
            <Sidebar />
            <Box ml="300px" pr="20px">
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Users" />
                </Box>

                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }}>
                    <StatisticCards onAddUserClick={handleAddUserClick} />
                    <UsersTable />

                    <Collapse in={showForm} animateOpacity>
                        <Box mt="40px" ref={formRef}>
                            <PersonalInfos
                                onTimeout={handleFormTimeout}
                                onPartialInput={handlePartialInput}
                            />
                        </Box>
                    </Collapse>
                </Box>
            </Box>

            {showPopup && <Popup onClose={() => setShowPopup(false)} />}
        </Box>
    );
}
