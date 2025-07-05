import { Box, useColorModeValue } from '@chakra-ui/react';
import Sidebar from '../component/Sidebar';
import Navbar from '../component/Navbar';
import CardSummaryPanel from '../component/CardSummaryPanel';
import CardTable from '../component/CardTable';
import NewRequestsTable from '../component/NewRequestsTable'; // ✅ Import here

export default function Cards() {
    const bg = useColorModeValue('#f4f7fe', '#0b1437');

    return (
        <Box minH="100vh" bg={bg} display="flex">
            {/* Sidebar */}
            <Sidebar />

            {/* Main area beside sidebar */}
            <Box ml="300px" flex="1" display="flex" flexDirection="column">
                {/* Fixed navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Cards" />
                </Box>

                {/* Main content */}
                <Box pt="180px" px={{ base: '20px', md: '40px', lg: '60px' }} flex="1">
                    <CardSummaryPanel />

                    <Box mb={10}>
                        <CardTable />
                    </Box>

                    <Box mt={4}>
                        <NewRequestsTable />
                    </Box>
                </Box>
            </Box>
        </Box>
    );
}
