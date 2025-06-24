import React from 'react';
import {
    Box, Text, Flex, Avatar, Button, useColorModeValue, Badge, VStack, Divider, SimpleGrid
} from '@chakra-ui/react';
import { EmailIcon, PhoneIcon, CalendarIcon, StarIcon, LockIcon, TimeIcon } from '@chakra-ui/icons';

const Profile = () => {
    const bgContainer = useColorModeValue('#ffffff', '#18214a');
    const gradientBg = useColorModeValue('#f4f7fe', 'linear(to-br, #131c34, #1e2a48)');
    const boxShadowColor = useColorModeValue('rgba(0, 0, 0, 0.1)', 'rgba(0,0,0,0.4)');
    const cardBg = useColorModeValue('#ffffff', '#22304c');
    const textColor = useColorModeValue('#0b1437', '#ffffff');
    const labelColor = useColorModeValue('gray.600', 'gray.400');

    // ✅ Using an online professional agent photo (replace with your own if needed)
    const profileImage =
        'https://i.imgur.com/zXjvZpQ.png';  // professional agent female profile

    return (
        <Box minH="100vh" bg={gradientBg} py={10} px={4}>
            <Box
                p={10}
                bg={bgContainer}
                borderRadius="xl"
                boxShadow={`0 4px 30px ${boxShadowColor}`}
                maxW="900px"
                mx="auto"
            >
                <Text fontSize="3xl" fontWeight="bold" mb={10} textAlign="center" color={textColor}>
                    Agent Profile
                </Text>

                <Box bg={cardBg} borderRadius="lg" boxShadow="md" p={8} mb={8} textAlign="center">
                    {/* Avatar with embedded image */}
                    <Box
                        mx="auto"
                        mb={4}
                        borderRadius="full"
                        border="4px solid"
                        borderColor="blue.400"
                        p="5px"
                        width="fit-content"
                        boxShadow="0 0 15px rgba(66,153,225,0.6)"
                    >
                        <Avatar size="2xl" name="Dianne Russell" src={profileImage} />
                    </Box>

                    <Text fontSize="2xl" fontWeight="bold" color={textColor}>
                        Dianne Russell
                    </Text>
                    <Text fontSize="md" color={labelColor} mb={2}>Role: Agent</Text>

                    {/* Fun badges */}
                    <Flex justify="center" gap={3} mt={3} flexWrap="wrap">
                        <Badge px={4} py={1} borderRadius="full" colorScheme="green" fontSize="0.9em">Active</Badge>
                        <Badge px={4} py={1} borderRadius="full" colorScheme="purple" fontSize="0.9em">⭐ Top Performer</Badge>
                        <Badge px={4} py={1} borderRadius="full" colorScheme="blue" fontSize="0.9em">🔒 Secure Access</Badge>
                    </Flex>
                </Box>

                {/* Activity Snapshot */}
                <SimpleGrid columns={[1, 3]} spacing={6} mb={8}>
                    <Box bg={cardBg} borderRadius="lg" p={6} textAlign="center" boxShadow="md">
                        <StarIcon boxSize={6} color="yellow.400" mb={3} />
                        <Text fontWeight="bold" fontSize="xl" color={textColor}>32</Text>
                        <Text color={labelColor}>Travel Plans Reviewed</Text>
                    </Box>

                    <Box bg={cardBg} borderRadius="lg" p={6} textAlign="center" boxShadow="md">
                        <LockIcon boxSize={6} color="cyan.300" mb={3} />
                        <Text fontWeight="bold" fontSize="xl" color={textColor}>18</Text>
                        <Text color={labelColor}>Cards Activated</Text>
                    </Box>

                    <Box bg={cardBg} borderRadius="lg" p={6} textAlign="center" boxShadow="md">
                        <TimeIcon boxSize={6} color="orange.300" mb={3} />
                        <Text fontWeight="bold" fontSize="xl" color={textColor}>3h ago</Text>
                        <Text color={labelColor}>Last Login</Text>
                    </Box>
                </SimpleGrid>

                {/* Contact Info */}
                <Box bg={cardBg} borderRadius="lg" boxShadow="md" p={8} mb={8}>
                    <VStack spacing={5} align="start">
                        <Box>
                            <Flex align="center" mb={1}><EmailIcon mr={2} /><Text fontWeight="semibold" color={labelColor}>Email:</Text></Flex>
                            <Text color={textColor}>dianne.russell@banking.com</Text>
                        </Box>

                        <Box>
                            <Flex align="center" mb={1}><PhoneIcon mr={2} /><Text fontWeight="semibold" color={labelColor}>Phone:</Text></Flex>
                            <Text color={textColor}>+212 600 000 000</Text>
                        </Box>

                        <Box>
                            <Flex align="center" mb={1}><CalendarIcon mr={2} /><Text fontWeight="semibold" color={labelColor}>Joined On:</Text></Flex>
                            <Text color={textColor}>2024-01-15</Text>
                        </Box>
                    </VStack>
                </Box>

                {/* Motivation quote */}
                <Box textAlign="center" mb={10}>
                    <Text fontSize="lg" fontStyle="italic" color={labelColor}>
                        “Empowering customers with speed and security!”
                    </Text>
                </Box>

                {/* Action buttons */}
                <Flex justify="center" gap={8}>
                    <Button colorScheme="blue" borderRadius="full" px={8}>Edit Profile</Button>
                    <Button colorScheme="red" variant="outline" borderRadius="full" px={8}>Deactivate</Button>
                </Flex>
            </Box>
        </Box>
    );
};

export default Profile;
