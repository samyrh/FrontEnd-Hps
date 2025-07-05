import React from "react";
import {
    Box,
    Flex,
    Avatar,
    Text,
    Badge,
    Button,
    Stack,
    useColorModeValue,
    SimpleGrid,
    VStack,
    HStack,
    Icon,
} from "@chakra-ui/react";
import { CheckCircleIcon, WarningIcon, LockIcon, RepeatIcon } from "@chakra-ui/icons";

export default function  Profile() {
    const bg = useColorModeValue("white", "#141f52");
    const cardBg = useColorModeValue("gray.100", "#1e2768");
    const textColor = useColorModeValue("gray.800", "white");
    const borderColor = useColorModeValue("gray.200", "#2c3475");
    const pageBg = useColorModeValue("gray.50", "#0b1437"); // Slightly darker page background

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
                <Flex
                    direction={{ base: "column", md: "row" }}
                    align="center"
                    justify="space-between"
                    mb={6}
                >
                    <HStack spacing={4}>
                        <Avatar size="xl" name="Sarah Thompson" src="https://i.pravatar.cc/150?img=32" />
                        <Box>
                            <Text fontSize="2xl" fontWeight="bold">
                                Sarah Thompson
                            </Text>
                            <Text>Agent</Text>
                            <HStack mt={2}>
                                <Badge colorScheme="green">Active</Badge>
                                <Text fontSize="sm" opacity={0.7}>
                                    Last login: 2 hours ago
                                </Text>
                            </HStack>
                        </Box>
                    </HStack>
                    <HStack mt={{ base: 4, md: 0 }}>
                        <Button colorScheme="blue">Edit Profile</Button>
                        <Button colorScheme="red" variant="outline">
                            Suspend Account
                        </Button>
                        <Button variant="ghost">Reset Password</Button>
                    </HStack>
                </Flex>

                <SimpleGrid columns={{ base: 1, md: 3 }} spacing={4} mb={4}>
                    {/* Capabilities */}
                    <Box bg={cardBg} p={4} borderRadius="lg" border="1px solid" borderColor={borderColor}>
                        <Text fontWeight="semibold" mb={2}>
                            Capabilities & Permissions
                        </Text>
                        <SimpleGrid columns={{ base: 1, md: 2 }} spacing={2}>
                            <HStack
                                bg={useColorModeValue("gray.100", "whiteAlpha.200")}
                                px={3}
                                py={2}
                                borderRadius="md"
                                spacing={2}
                            >
                                <CheckCircleIcon color="green.400" />
                                <Text fontSize="sm">CVV Regenerated</Text>
                            </HStack>
                            <HStack
                                bg={useColorModeValue("gray.100", "whiteAlpha.200")}
                                px={3}
                                py={2}
                                borderRadius="md"
                                spacing={2}
                            >
                                <CheckCircleIcon color="green.400" />
                                <Text fontSize="sm">Block/Unblock Card</Text>
                            </HStack>
                            <HStack
                                bg={useColorModeValue("gray.100", "whiteAlpha.200")}
                                px={3}
                                py={2}
                                borderRadius="md"
                                spacing={2}
                            >
                                <CheckCircleIcon color="green.400" />
                                <Text fontSize="sm">Travel Plan Review</Text>
                            </HStack>
                            <HStack
                                bg={useColorModeValue("red.50", "red.400")}
                                px={3}
                                py={2}
                                borderRadius="md"
                                spacing={2}
                            >
                                <WarningIcon color={useColorModeValue("red.500", "white")} />
                                <Text fontSize="sm">Admin Access</Text>
                            </HStack>
                        </SimpleGrid>
                    </Box>


                    {/* Security */}
                    <Box bg={cardBg} p={4} borderRadius="lg" border="1px solid" borderColor={borderColor}>
                        <Text fontWeight="semibold" mb={2}>
                            Security & Authentication
                        </Text>
                        <VStack align="start" spacing={2}>
                            <HStack>
                                <CheckCircleIcon color="green.400" />
                                <Text>2FA Enabled</Text>
                            </HStack>
                            <HStack>
                                <CheckCircleIcon color="green.400" />
                                <Text>Security Code Setup</Text>
                            </HStack>
                            <HStack>
                                <LockIcon color="gray.400" />
                                <Text>Biometric Login</Text>
                            </HStack>
                            <HStack>
                                <LockIcon color="gray.400" />
                                <Text>Account Locked</Text>
                            </HStack>
                        </VStack>
                        <Text mt={3} fontWeight="semibold">
                            Roles
                        </Text>
                        <Stack mt={1}>
                            <Badge colorScheme="green">Card Support Agent</Badge>
                            <Badge colorScheme="green">Travel Plan Agent</Badge>
                        </Stack>
                    </Box>

                    {/* Assigned Cardholders */}
                    <Box bg={cardBg} p={4} borderRadius="lg" border="1px solid" borderColor={borderColor}>
                        <Text fontWeight="semibold" mb={2}>
                            Assigned Cardholders
                        </Text>
                        <VStack align="start" spacing={3}>
                            <HStack justify="space-between" w="full">
                                <HStack>
                                    <Avatar size="sm" name="John Doe" />
                                    <Text>John Doe</Text>
                                </HStack>
                                <Badge colorScheme="green">Active</Badge>
                            </HStack>
                            <HStack justify="space-between" w="full">
                                <HStack>
                                    <Avatar size="sm" name="Jane Smith" />
                                    <Text>Jane Smith</Text>
                                </HStack>
                                <Badge colorScheme="yellow">Suspended</Badge>
                            </HStack>
                            <HStack justify="space-between" w="full">
                                <HStack>
                                    <Avatar size="sm" name="Michael Doe" />
                                    <Text>Michael Doe</Text>
                                </HStack>
                                <Badge colorScheme="gray">PIN Reset</Badge>
                            </HStack>
                        </VStack>
                    </Box>
                </SimpleGrid>

                <SimpleGrid columns={{ base: 1, md: 2 }} spacing={4}>
                    {/* Recent Cardholder Actions */}
                    <Box bg={cardBg} p={4} borderRadius="lg" border="1px solid" borderColor={borderColor}>
                        <Text fontWeight="semibold" mb={2}>
                            Recent Cardholder Actions
                        </Text>
                        <VStack align="start" spacing={3}>
                            <HStack>
                                <Icon as={RepeatIcon} color="blue.400" />
                                <Text>CVV Regenerated – John Doe</Text>
                            </HStack>
                            <HStack>
                                <Icon as={CheckCircleIcon} color="blue.400" />
                                <Text>Travel Plan Approved – Spain Trip</Text>
                            </HStack>
                            <HStack>
                                <Icon as={WarningIcon} color="red.400" />
                                <Text>Card Blocked – Fraud Suspected</Text>
                            </HStack>
                            <HStack>
                                <Icon as={LockIcon} color="gray.400" />
                                <Text>Card Cancellation in Progress</Text>
                            </HStack>
                        </VStack>
                    </Box>

                    {/* Activity Log */}
                    <Box bg={cardBg} p={4} borderRadius="lg" border="1px solid" borderColor={borderColor}>
                        <Text fontWeight="semibold" mb={2}>
                            Activity Log
                        </Text>
                        <VStack align="start" spacing={2}>
                            <Text>06.10.24 – Approved Travel Plan</Text>
                            <Text>06.08.24 – Reset Card PIN</Text>
                            <Text>06.07.24 – Blocked Card (Fraud)</Text>
                            <Text>06.07.24 – Created Cardholder Account</Text>
                        </VStack>
                    </Box>
                </SimpleGrid>
            </Box>
        </Flex>
    );
}
