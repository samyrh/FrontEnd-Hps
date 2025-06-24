import React from 'react';
import { Box, useColorModeValue } from '@chakra-ui/react';
import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import StatisticCards from '../component/StatisticCards';
import UsersTable from '../component/UsersTable';
import Footer from '../component/Footer';

export default function Users() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');

    return (
        <Box minH="100vh" bg={bg}>
            {/* Sidebar */}
            <Sidebar />

            {/* Main content area with margin to accommodate sidebar */}
            <Box ml="300px" pr="20px">
                {/* Fixed Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Users" />
                </Box>

                {/* Page content */}
                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }}>
                    {/* Add User button + Stats */}
                    <StatisticCards />

                    {/* Users table */}
                    <UsersTable />

                </Box>
            </Box>
            <Footer />
        </Box>
    );
} 