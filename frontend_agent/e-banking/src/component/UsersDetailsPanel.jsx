import React from "react";
import {
    Box,
    Flex,
    Avatar,
    Text,
    Badge,
    Button,
    HStack,
    VStack,
    SimpleGrid,
    useColorModeValue,
    Icon,
} from "@chakra-ui/react";
import {
    CheckCircleIcon,
    LockIcon,
    RepeatIcon,
    WarningIcon,
} from "@chakra-ui/icons";

export default function UserDetailsPanel() {
    const pageBg = useColorModeValue("gray.50", "#0b1437");
    const bg = useColorModeValue("white", "#141f52");
    const cardBg = useColorModeValue("gray.100", "#1e2768");
    const textColor = useColorModeValue("gray.800", "white");
    const borderColor = useColorModeValue("gray.200", "#2c3475");

    const user = {
        name: "Youssef Amrani",
        email: "youssef.amrani@gmail.com",
        status: "Active",
        biometric: true,
        totalCards: 3,
        physicalCards: 1,
        virtualCards: 2,
        lastLogin: "2 hours ago",
    };

    return (
        <Flex
            bg={pageBg}
            minH="100vh"
            justify="center"
            align="start"
            p={6}
        >
            <Box
                bg={bg}
                color={textColor}
                w="100%"
                maxW="1200px"
                borderRadius="2xl"
                boxShadow="lg"
                p={6}
            >
                {/* Top Section */}
                <Flex
                    direction={{ base: "column", md: "row" }}
                    align="center"
                    justify="space-between"
                    mb={6}
                >
                    <HStack spacing={4}>
                        <Avatar size="xl" name={user.name} />
                        <Box>
                            <Text fontSize="2xl" fontWeight="bold">{user.name}</Text>
                            <Text>{user.email}</Text>
                            <HStack mt={2}>
                                <Badge colorScheme="green">{user.status}</Badge>
                                <Text fontSize="sm" opacity={0.7}>Last login: {user.lastLogin}</Text>
                            </HStack>
                        </Box>
                    </HStack>
                </Flex>

                {/* Info Cards */}
                <SimpleGrid columns={{ base: 1, md: 3 }} spacing={4} mb={4}>
                    <Box
                        bg={cardBg}
                        p={4}
                        borderRadius="lg"
                        border="1px solid"
                        borderColor={borderColor}
                    >
                        <Text fontWeight="semibold" mb={2}>Biometric</Text>
                        <Badge
                            colorScheme={user.biometric ? "green" : "red"}
                            borderRadius="full"
                            px={4}
                            py={1}
                        >
                            {user.biometric ? "Enabled" : "Disabled"}
                        </Badge>
                    </Box>
                    <Box
                        bg={cardBg}
                        p={4}
                        borderRadius="lg"
                        border="1px solid"
                        borderColor={borderColor}
                    >
                        <Text fontWeight="semibold" mb={2}>Total Cards</Text>
                        <Text fontWeight="bold" fontSize="2xl">{user.totalCards}</Text>
                    </Box>
                    <Box
                        bg={cardBg}
                        p={4}
                        borderRadius="lg"
                        border="1px solid"
                        borderColor={borderColor}
                    >
                        <Text fontWeight="semibold" mb={2}>Physical Cards</Text>
                        <Text fontWeight="bold" fontSize="2xl">{user.physicalCards}</Text>
                    </Box>
                </SimpleGrid>

                <SimpleGrid columns={{ base: 1, md: 2 }} spacing={4} mb={4}>
                    <Box
                        bg={cardBg}
                        p={4}
                        borderRadius="lg"
                        border="1px solid"
                        borderColor={borderColor}
                    >
                        <Text fontWeight="semibold" mb={2}>Virtual Cards</Text>
                        <Text fontWeight="bold" fontSize="2xl">{user.virtualCards}</Text>
                    </Box>
                    <Box
                        bg={cardBg}
                        p={4}
                        borderRadius="lg"
                        border="1px solid"
                        borderColor={borderColor}
                    >
                        <Text fontWeight="semibold" mb={2}>Recent Activity</Text>
                        <VStack align="start" spacing={3}>
                            <HStack>
                                <Icon as={RepeatIcon} color="blue.400" />
                                <Text>CVV Regenerated</Text>
                            </HStack>
                            <HStack>
                                <Icon as={CheckCircleIcon} color="green.400" />
                                <Text>Travel Plan Approved</Text>
                            </HStack>
                            <HStack>
                                <Icon as={WarningIcon} color="red.400" />
                                <Text>Card Blocked – Fraud</Text>
                            </HStack>
                        </VStack>
                    </Box>
                </SimpleGrid>

                {/* Action Button */}
                <Flex justify="center" mt={6}>
                    <Button
                        bg="#ff9e9e"
                        color="black"
                        fontWeight="bold"
                        borderRadius="16px"
                        _hover={{ bg: "#b31c1c", color: "white" }}
                        px={10}
                        py={6}
                    >
                        Suspend User
                    </Button>
                </Flex>
            </Box>
        </Flex>
    );
}
