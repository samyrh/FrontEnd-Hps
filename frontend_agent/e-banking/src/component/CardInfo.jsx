import {
    Box,
    Flex,
    Text,
    Button,
    Input,
    Select,
    useColorModeValue,
    Icon,
} from '@chakra-ui/react';
import { useState } from 'react';
import { RefreshCcw, PlusCircle, KeyRound } from 'lucide-react';

export default function CardInfo() {
    const sectionBg = useColorModeValue('white', '#18214a');
    const btnBg = useColorModeValue('#E2E8F0', '#1a1f3c');
    const [isFront, setIsFront] = useState(true);

    return (
        <>
            {/* Top: Card + Right Side (Status + Block Sections) */}
            <Flex gap={6} wrap="wrap">
                {/* Left: Card + Cancel Card */}
                <Box>
                    {/* 💳 Card Container */}
                    <Box bg={sectionBg} borderRadius="20px" p={5} mb={4} w="fit-content">
                        <Box
                            bgGradient="linear(to-r, #ff9a9e, #fad0c4)"
                            w="320px"
                            h="160px"
                            borderRadius="20px"
                            p={5}
                            cursor="pointer"
                            onClick={() => setIsFront(!isFront)}
                            boxShadow="lg"
                            transition="transform 0.6s ease-in-out"
                            transform={isFront ? 'rotateY(0deg)' : 'rotateY(180deg)'}
                            transformStyle="preserve-3d"
                        >
                            {isFront ? (
                                <>
                                    <Text color="white" fontSize="sm" mb={4}>•••• 4631</Text>
                                    <Text color="white" fontSize="xs">08/28</Text>
                                    <Text color="white" fontWeight="bold" fontSize="lg" mt={8}>VISA</Text>
                                </>
                            ) : (
                                <>
                                    <Text color="white" fontSize="xs" mb={2}>CVV</Text>
                                    <Text color="white" fontSize="2xl">•••</Text>
                                </>
                            )}
                        </Box>
                    </Box>

                    {/* ❌ Cancel Card Section */}
                    <Box bg={sectionBg} borderRadius="20px" p={4} w="355px">
                        <Text fontWeight="bold" mb={2}>Cancel Card</Text>
                        <Flex gap={2}>
                            <Button colorScheme="pink" flex="1">Request Virtual Card</Button>
                            <Button colorScheme="red" flex="1">Cancel Card</Button>
                        </Flex>
                    </Box>
                </Box>

                {/* Right: Status + Block + TempBlock */}
                <Flex direction="column" gap={6} flex="1" minW="320px">
                    {/* 🟢 Status Box */}
                    <Box bg={sectionBg} borderRadius="20px" p={4} minH="160px">
                        <Text fontWeight="bold" mb={1}>Status</Text>
                        <Text color="green.400">● Active</Text>
                    </Box>

                    {/* Temp + Block side by side */}
                    <Flex gap={6} wrap="wrap">
                        {/* 🕓 Temporary Block */}
                        <Box
                            bg={sectionBg}
                            borderRadius="20px"
                            p={4}
                            flex="1"
                            minW="260px"
                        >
                            <Text fontWeight="bold" mb={2}>Temporary Block</Text>
                            <Input placeholder="Start Date" mb={2} type="date" />
                            <Input placeholder="End Date" type="date" />
                        </Box>

                        {/* 🚫 Block Card */}
                        <Box
                            bg={sectionBg}
                            borderRadius="20px"
                            p={4}
                            flex="1"
                            minW="260px"
                        >
                            <Text fontWeight="bold" mb={2}>Block Card</Text>
                            <Select placeholder="Select reason" mb={3}>
                                <option>Card Lost</option>
                                <option>Stolen</option>
                                <option>Unauthorized Use</option>
                            </Select>
                            <Button colorScheme="red" w="100%">Block Card</Button>
                        </Box>
                    </Flex>
                </Flex>
            </Flex>

            {/* 🔘 Bottom Buttons */}
            <Flex mt={12} gap={4} flexWrap="wrap" justify="center" w="100%">
                <Button
                    leftIcon={<Icon as={RefreshCcw} />}
                    bg={btnBg}
                    color="white"
                    _hover={{ bg: '#202442' }}
                >
                    Regenerate CVV
                </Button>
                <Button
                    leftIcon={<Icon as={KeyRound} />}
                    bg={btnBg}
                    color="white"
                    _hover={{ bg: '#202442' }}
                >
                    Regenerate PIN
                </Button>
                <Button
                    leftIcon={<Icon as={PlusCircle} />}
                    bg={btnBg}
                    color="white"
                    _hover={{ bg: '#202442' }}
                >
                    Request New Card
                </Button>
            </Flex>
        </>
    );
}
