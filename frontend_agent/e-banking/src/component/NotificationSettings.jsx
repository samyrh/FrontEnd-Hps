// src/component/NotificationSettings.jsx
import {
    Box,
    Button,
    VStack,
    Text,
    Flex,
    useDisclosure,
    AlertDialog,
    AlertDialogBody,
    AlertDialogFooter,
    AlertDialogContent,
    AlertDialogOverlay,
    useColorModeValue,
    Icon,
} from '@chakra-ui/react';
import { useRef, useState } from 'react';
import { FaMobileAlt, FaEnvelope } from 'react-icons/fa';

function NotificationToggle({ selected, onChange }) {
    const isInApp = selected === 'inApp';
    const isEmail = selected === 'email';

    const bg = useColorModeValue('#e0d7f7', '#0b1437');
    const activeBg = useColorModeValue('#b832f6', '#b832f6');
    const inactiveText = useColorModeValue('black', 'gray.300');

    return (
        <Flex bg={bg} borderRadius="12px" overflow="hidden">
            <Flex
                align="center"
                gap="2"
                px="3"
                py="1"
                bg={isInApp ? activeBg : 'transparent'}
                color={isInApp ? 'white' : inactiveText}
                cursor="pointer"
                onClick={() => onChange('inApp')}
            >
                <Icon as={FaMobileAlt} />
                <Text fontSize="sm">In-app</Text>
            </Flex>

            <Flex
                align="center"
                gap="2"
                px="3"
                py="1"
                bg={isEmail ? activeBg : 'transparent'}
                color={isEmail ? 'white' : inactiveText}
                cursor="pointer"
                onClick={() => onChange('email')}
            >
                <Icon as={FaEnvelope} />
                <Text fontSize="sm">Email</Text>
            </Flex>
        </Flex>
    );
}

export default function NotificationSettings() {
    const cardBg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('black', 'white');
    const rowBg = useColorModeValue('#f4f4f9', '#1e2a63');

    const { isOpen, onOpen, onClose } = useDisclosure();
    const cancelRef = useRef();

    const [generalToggles, setGeneralToggles] = useState(['inApp', 'inApp', 'inApp', 'inApp']);
    const [summaryToggles, setSummaryToggles] = useState(['inApp', 'inApp', 'inApp', 'inApp']);

    return (
        <Box bg={cardBg} p="6" borderRadius="20px" boxShadow="md">
            {/* General Notifications */}
            <Box mb="8">
                <Text fontSize="md" fontWeight="bold" color={textColor} mb="2">
                    General notifications
                </Text>
                <Text fontSize="sm" color="gray.400" mb="4">
                    Lorem ipsum dolor sit amet consectetur adipiscing.
                </Text>
                <VStack spacing="4">
                    {[
                        "I'm mentioned in a message",
                        'Someone replies to any message',
                        "I'm assigned a task",
                        'A task is overdue',
                    ].map((label, i) => (
                        <Flex
                            w="full"
                            justify="space-between"
                            align="center"
                            bg={rowBg}
                            p="3"
                            borderRadius="md"
                            key={i}
                        >
                            <Text color={textColor} fontSize="sm">
                                {label}
                            </Text>
                            <NotificationToggle
                                selected={generalToggles[i]}
                                onChange={(val) => {
                                    const newToggles = [...generalToggles];
                                    newToggles[i] = val;
                                    setGeneralToggles(newToggles);
                                }}
                            />
                        </Flex>
                    ))}
                </VStack>
            </Box>

            {/* Summary Notifications */}
            <Box mb="8">
                <Text fontSize="md" fontWeight="bold" color={textColor} mb="2">
                    Summary notifications
                </Text>
                <Text fontSize="sm" color="gray.400" mb="4">
                    Lorem ipsum dolor sit amet consectetur adipiscing.
                </Text>
                <VStack spacing="4">
                    {['Daily summary', 'Weekly summary', 'Monthly summary', 'Annually summary'].map(
                        (label, i) => (
                            <Flex
                                w="full"
                                justify="space-between"
                                align="center"
                                bg={rowBg}
                                p="3"
                                borderRadius="md"
                                key={i}
                            >
                                <Text color={textColor} fontSize="sm">
                                    {label}
                                </Text>
                                <NotificationToggle
                                    selected={summaryToggles[i]}
                                    onChange={(val) => {
                                        const newToggles = [...summaryToggles];
                                        newToggles[i] = val;
                                        setSummaryToggles(newToggles);
                                    }}
                                />
                            </Flex>
                        )
                    )}
                </VStack>
            </Box>

            {/* Add User Button */}
            <Flex justify="flex-end">
                <Button
                    bg="purple.500"
                    color="white"
                    _hover={{ bg: 'purple.600' }}
                    onClick={onOpen}
                >
                    Add User
                </Button>
            </Flex>

            {/* Success Modal */}
            <AlertDialog
                isOpen={isOpen}
                leastDestructiveRef={cancelRef}
                onClose={onClose}
                isCentered
                motionPreset="scale"
            >
                <AlertDialogOverlay>
                    <AlertDialogContent
                        bg={cardBg}
                        borderRadius="xl"
                        py="8"
                        px="6"
                        textAlign="center"
                        boxShadow="2xl"
                    >
                        <Flex justify="center" mb="5">
                            <Box
                                fontSize="40px"
                                bgGradient="linear(to-r, #ff6ec4, #7873f5)"
                                borderRadius="full"
                                w="60px"
                                h="60px"
                                display="flex"
                                alignItems="center"
                                justifyContent="center"
                                boxShadow="0 0 20px rgba(255, 110, 196, 0.4)"
                                animation="pulse 1.5s infinite"
                            >
                                🎉
                            </Box>
                        </Flex>

                        <AlertDialogBody fontSize="lg" fontWeight="semibold" color={textColor}>
                            User has been created successfully!
                        </AlertDialogBody>

                        <AlertDialogFooter justifyContent="center" mt="6">
                            <Button
                                onClick={onClose}
                                ref={cancelRef}
                                bgGradient="linear(to-r, #9F7AEA, #D53F8C)"
                                color="white"
                                px="6"
                                py="2"
                                borderRadius="lg"
                                _hover={{ opacity: 0.9 }}
                                _active={{ transform: 'scale(0.97)' }}
                            >
                                OK
                            </Button>
                        </AlertDialogFooter>
                    </AlertDialogContent>
                </AlertDialogOverlay>
            </AlertDialog>
        </Box>
    );
}
