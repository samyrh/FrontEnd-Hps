
import { Box, useColorModeValue } from '@chakra-ui/react';
import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import UserDetailsPanel from '../component/UsersDetailsPanel'; // ✅ ton composant de détails

export default function UsersDetails() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');

    return (
        <Box minH="100vh" bg={bg} display="flex">
            {/* Sidebar */}
            <Sidebar />

            {/* Main area beside sidebar */}
            <Box ml="300px" flex="1" display="flex" flexDirection="column">
                {/* Fixed Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="User Details" />
                </Box>

                {/* Page content below navbar */}
                <Box
                    pt="180px"
                    px={{ base: '20px', md: '40px', lg: '60px' }}
                    pb="40px"
                    flex="1"
                >
                    <UserDetailsPanel />
                </Box>
            </Box>
        </Box>
    );
}
