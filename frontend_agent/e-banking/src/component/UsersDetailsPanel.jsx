import {
    Box,
    Text,
    Avatar,
    Badge,
    Button,
    SimpleGrid,
    Flex,
    useColorModeValue,
} from '@chakra-ui/react';

export default function UserDetailsPanel() {
    const user = {
        name: 'Youssef Amrani',
        email: 'youssef.amrani@gmail.com',
        status: 'active',
        biometric: true,
        totalCards: 3,
        physicalCards: 1,
        virtualCards: 1,
    };

    const boxBg = useColorModeValue('#0d1c3f', '#0d1c3f');
    const labelColor = useColorModeValue('gray.400', 'gray.400');

    return (
        <Box
            bg="#0a1735"
            color="white"
            borderRadius="24px"
            px={14}
            py={12}
            maxW="1200px"
            minH="520px"
            mx="auto"
            boxShadow="dark-lg"
        >
            {/* Top Section */}
            <Box bg={boxBg} p={6} borderRadius="20px" mb={8}>
                <Flex justify="space-between" align="center" flexWrap="wrap">
                    <Flex align="center" gap={6}>
                        <Avatar name={user.name} bg="green.400" color="white" size="xl" />
                        <Box>
                            <Text fontWeight="bold" fontSize="2xl">{user.name}</Text>
                            <Text fontSize="md" color={labelColor}>{user.email}</Text>
                        </Box>
                    </Flex>
                </Flex>
            </Box>

            {/* Info Cards */}
            <SimpleGrid columns={{ base: 2, md: 3 }} spacing={6} mb={8}>
                <Box bg={boxBg} p={6} borderRadius="16px">
                    <Text fontSize="sm" color={labelColor}>Status</Text>
                    <Badge mt={2} colorScheme="teal" borderRadius="full" px={4} py={1}>
                        Active
                    </Badge>
                </Box>

                <Box bg={boxBg} p={6} borderRadius="16px">
                    <Text fontSize="sm" color={labelColor}>Biometric</Text>
                    <Badge
                        mt={2}
                        colorScheme={user.biometric ? 'green' : 'red'}
                        borderRadius="full"
                        px={4}
                        py={1}
                    >
                        {user.biometric ? 'Enabled' : 'Disabled'}
                    </Badge>
                </Box>

                <Box bg={boxBg} p={6} borderRadius="16px">
                    <Text fontSize="sm" color={labelColor}>Cards</Text>
                    <Text mt={2} fontWeight="bold">{user.totalCards}</Text>
                </Box>
            </SimpleGrid>

            {/* Card Types */}
            <SimpleGrid columns={{ base: 2, md: 2 }} spacing={6}>
                <Box bg={boxBg} p={6} borderRadius="16px">
                    <Text fontSize="sm" color={labelColor}>Physical Cards</Text>
                    <Text mt={2} fontWeight="bold">{user.physicalCards}</Text>
                </Box>

                <Box bg={boxBg} p={6} borderRadius="16px">
                    <Text fontSize="sm" color={labelColor}>Virtual Cards</Text>
                    <Text mt={2} fontWeight="bold">{user.virtualCards}</Text>
                </Box>
            </SimpleGrid>

            {/* Suspend Button Centered */}
            <Flex justify="center" mt={8}>
                <Button
                    bg="#ff9e9e"
                    color="black"
                    fontWeight="bold"
                    borderRadius="16px"
                    _hover={{ bg: '#b31c1c' }}
                    px={10}
                    py={6}
                >
                    Suspend User
                </Button>
            </Flex>
        </Box>
    );
}
