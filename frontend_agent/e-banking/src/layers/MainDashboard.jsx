// src/layers/MainDashboard.js
import React from 'react';
import { Box, Flex, useColorModeValue } from '@chakra-ui/react';
import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import StatCardGrid from '../component/StatCardGrid';
import ComplexTable from '../component/ComplexTable';
import MiniCalendar from '../component/MiniCalendar';
import Footer from '../component/Footer';
export default function MainDashboard() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');

    return (
        <Box minH="100vh" bg={bg}>
            <Sidebar />

            <Box ml="300px" pr="20px">
                {/* Fixed Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Main Dashboard" />
                </Box>

                {/* Page content */}
                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }}>
                    <Box mb="40px">
                        <StatCardGrid />
                    </Box>

                    <Flex
                        direction={{ base: 'column', md: 'row' }}
                        gap="24px"
                        align="flex-start"
                    >
                        <Box flex="1" mb="60px">
                            <ComplexTable />
                        </Box>
                        <Box flex="1">
                            <MiniCalendar />
                        </Box>
                    </Flex>
                </Box>
            </Box>
            <Footer />

        </Box>
    );
}
