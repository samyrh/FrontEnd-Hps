import { Box, Flex, Divider, useColorModeValue } from '@chakra-ui/react';
import { useState } from 'react';

// Global styles (custom CSS classes or animations)
import '../style/GlobalAddUser.css';

import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import CredentialsSidebar from '../component/CredentialsSidebar';
import PersonalInfos from '../component/PersonalInfos';
import BasicInfos from '../component/BasicInfos';
import CreateCard from '../component/CreateCard';
import NotificationSettings from '../component/NotificationSettings';
import Footer from '../component/Footer';

export default function AddUser() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');
    const [selectedSection, setSelectedSection] = useState('personal');

    const renderContent = () => {
        switch (selectedSection) {
            case 'billing':
                return <CreateCard />;
            case 'notifications':
                return <NotificationSettings />;
            case 'personal':
            default:
                return (
                    <>
                        <PersonalInfos />
                        <Box mt="40px">
                            <BasicInfos />
                        </Box>
                    </>
                );
        }
    };

    return (
        <Box minH="100vh" bg={bg} className="add-user-page">
            <Sidebar />

            <Box ml="300px" pr="20px">
                {/* Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Add User" />
                </Box>

                {/* Main Content */}
                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }}>
                    <Flex align="flex-start">
                        <CredentialsSidebar
                            selectedSection={selectedSection}
                            onSelect={setSelectedSection}
                        />
                        <Divider orientation="vertical" height="100%" mx="40px" borderColor="gray.700" />
                        <Box flex="1" mb="80px">
                            {renderContent()}
                        </Box>
                    </Flex>
                </Box>
            </Box>

            {/* Footer */}
            <Footer />
        </Box>
    );
}
