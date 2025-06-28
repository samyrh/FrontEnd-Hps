// src/layers/Notifications.jsx
import { Box, useColorModeValue, Text, Flex } from '@chakra-ui/react';
import { useState } from 'react';
import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import Filter from '../component/Filter';
import Notif from '../component/Notif';

const mockNotifications = [
    {
        id: 1,
        type: 'Alerts',
        title: 'Card Blocked',
        description: 'Card ending with 4631 was blocked due to suspicious activity.',
        date: '2024-06-27',
    },
    {
        id: 2,
        type: 'Transactions',
        title: 'Transaction Approved',
        description: 'Payment of $120 approved on your card.',
        date: '2024-06-27',
    },
    {
        id: 3,
        type: 'Travel Plans',
        title: 'New Travel Plan Added',
        description: 'Travel plan created for France from 01/07 to 15/07.',
        date: '2024-06-25',
    },
    {
        id: 4,
        type: 'Alerts',
        title: 'Pin Regenerated',
        description: 'The card PIN has been successfully regenerated.',
        date: '2024-06-20',
    },
];

export default function Notifications() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');
    const [activeFilter, setActiveFilter] = useState('All');

    const filteredNotifications =
        activeFilter === 'All'
            ? mockNotifications
            : mockNotifications.filter((n) => n.type === activeFilter);

    return (
        <Box minH="100vh" bg={bg} display="flex">
            <Sidebar />

            <Box ml="300px" flex="1" display="flex" flexDirection="column">
                {/* Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Notifications" />
                </Box>

                {/* Content */}
                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }} pb="40px" flex="1">
                    <Filter activeFilter={activeFilter} setActiveFilter={setActiveFilter} />

                    <Flex direction="column" gap={4}>
                        {filteredNotifications.map((n) => (
                            <Notif
                                key={n.id}
                                title={n.title}
                                description={n.description}
                                date={n.date}
                                type={n.type}
                            />
                        ))}

                        {filteredNotifications.length === 0 && (
                            <Text>No notifications in this category.</Text>
                        )}
                    </Flex>
                </Box>
            </Box>
        </Box>
    );
}
