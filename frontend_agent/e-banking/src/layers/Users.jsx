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

export default function Users() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');
    const [showForm, setShowForm] = useState(false);
    const formRef = useRef(null);

    // Scroll to form when it's shown
    useEffect(() => {
        if (showForm && formRef.current) {
            setTimeout(() => {
                formRef.current.scrollIntoView({ behavior: 'smooth' });
            }, 200); // wait for the collapse animation to start
        }
    }, [showForm]);

    return (
        <Box minH="100vh" bg={bg}>
            <Sidebar />

            <Box ml="300px" pr="20px">
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Users" />
                </Box>

                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }}>
                    {/* Stats + Add User Button */}
                    <StatisticCards onAddUserClick={() => setShowForm(true)} />

                    {/* Users Table */}
                    <UsersTable />

                    {/* Sliding Form with scroll-to-view */}
                    <Collapse in={showForm} animateOpacity>
                        <Box mt="40px" ref={formRef}>
                            <PersonalInfos />
                        </Box>
                    </Collapse>
                </Box>
            </Box>
        </Box>
    );
}
