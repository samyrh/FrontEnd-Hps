import {
    Box,
    Flex,
    Text,
    Button,
    Input,
    Select,
    useColorModeValue,
    Icon,
    useToast,
} from '@chakra-ui/react';
import { useState } from 'react';
import { RefreshCcw, KeyRound, Lock } from 'lucide-react';
import ActionSuccessModal from './ActionSuccessModal';
import RegenerateCodeModal from './RegenerateCodeModal';

export default function CardInfo() {
    const sectionBg = useColorModeValue('white', '#18214a');
    const selectBg = useColorModeValue('white', '#1f2a48');

    const [isFront, setIsFront] = useState(true);

    // Modal State
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [modalProps, setModalProps] = useState({
        title: '',
        description: '',
        badgeLabel: '',
        type: 'success',
    });

    const [selectedReason, setSelectedReason] = useState('');
    const [isRegenerateOpen, setIsRegenerateOpen] = useState(false);
    const [regenerateType, setRegenerateType] = useState('CVV');

    const toast = useToast();

    const cardNumber = '•••• 4631';

    return (
        <>
            {/* Top: Card + Right Side */}
            <Flex gap={6} wrap="wrap">
                {/* Left: Card + Cancel */}
                <Box>
                    {/* Card */}
                    <Box
                        bg={sectionBg}
                        borderRadius="20px"
                        p={5}
                        mb={4}
                        w="fit-content"
                        border="1px solid"
                        borderColor={useColorModeValue('gray.200', 'transparent')}
                        boxShadow={useColorModeValue('sm', 'none')}
                    >
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
                                    <Text color="white" fontSize="sm" mb={4}>{cardNumber}</Text>
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

                    {/* Cancel Card */}
                    <Box
                        bg={sectionBg}
                        borderRadius="20px"
                        p={4}
                        w="355px"
                        border="1px solid"
                        borderColor={useColorModeValue('gray.200', 'transparent')}
                        boxShadow={useColorModeValue('sm', 'none')}
                    >
                        <Text fontWeight="bold" mb={2}>Cancel Card</Text>
                        <Flex gap={2}>
                            <Button
                                colorScheme="red"
                                flex="1"
                                onClick={() => {
                                    setModalProps({
                                        title: 'Card Canceled',
                                        description: 'The following card was canceled successfully:',
                                        badgeLabel: cardNumber,
                                        type: 'error',
                                    });
                                    setIsModalOpen(true);
                                }}
                            >
                                Cancel Card
                            </Button>
                        </Flex>
                    </Box>
                </Box>

                {/* Right: Status + Block */}
                <Flex direction="column" gap={6} flex="1" minW="320px">
                    {/* Status */}
                    <Box
                        bg={sectionBg}
                        borderRadius="20px"
                        p={4}
                        minH="160px"
                        border="1px solid"
                        borderColor={useColorModeValue('gray.200', 'transparent')}
                        boxShadow={useColorModeValue('sm', 'none')}
                    >
                        <Text fontWeight="bold" mb={1}>Status</Text>
                        <Text color="green.400">● Active</Text>
                    </Box>

                    {/* Block Sections */}
                    <Flex gap={6} wrap="wrap">
                        {/* Permanently Block */}
                        <Box
                            bg={sectionBg}
                            borderRadius="20px"
                            p={4}
                            flex="1"
                            minW="260px"
                            border="1px solid"
                            borderColor={useColorModeValue('gray.200', 'transparent')}
                            boxShadow={useColorModeValue('sm', 'none')}
                        >
                            <Text fontWeight="bold" mb={2}>Permanently Block</Text>
                            <Input placeholder="Start Date" mb={2} type="date" />
                            <Input placeholder="End Date" type="date" />
                        </Box>

                        {/* Block Card */}
                        <Box
                            bg={sectionBg}
                            borderRadius="20px"
                            p={5}
                            flex="1"
                            minW="280px"
                            boxShadow={useColorModeValue('sm', 'none')}
                            border="1px solid"
                            borderColor={useColorModeValue('gray.200', 'transparent')}
                        >
                            <Flex align="center" mb={3}>
                                <Box
                                    bg="red.50"
                                    borderRadius="full"
                                    p={2}
                                    display="flex"
                                    alignItems="center"
                                    justifyContent="center"
                                    mr={2}
                                >
                                    <Icon as={Lock} color="red.500" boxSize={4} />
                                </Box>
                                <Text fontWeight="bold" fontSize="md">
                                    Block Card
                                </Text>
                            </Flex>

                            <Text fontSize="sm" color="gray.500" mb={3}>
                                Select the reason for blocking this card:
                            </Text>

                            <Select
                                placeholder="Select reason"
                                mb={4}
                                bg={selectBg}
                                borderColor={useColorModeValue('gray.300', 'gray.600')}
                                _hover={{ borderColor: useColorModeValue('gray.400', 'gray.500') }}
                                _focus={{
                                    borderColor: 'red.500',
                                    boxShadow: '0 0 0 1px red',
                                }}
                                color={useColorModeValue('black', 'white')}
                                value={selectedReason}
                                onChange={(e) => setSelectedReason(e.target.value)}
                            >
                                <option>Card Lost</option>
                                <option>Stolen</option>
                                <option>Unauthorized Use</option>
                            </Select>

                            <Button
                                colorScheme="red"
                                w="100%"
                                borderRadius="md"
                                size="md"
                                fontWeight="semibold"
                                onClick={() => {
                                    if (!selectedReason) {
                                        toast({
                                            title: 'Please select a reason.',
                                            status: 'warning',
                                            duration: 3000,
                                            isClosable: true,
                                        });
                                    } else {
                                        setModalProps({
                                            title: 'Card Blocked',
                                            description: 'The card was blocked for the following reason:',
                                            badgeLabel: selectedReason,
                                            type: 'error',
                                        });
                                        setIsModalOpen(true);
                                    }
                                }}
                            >
                                Block Card
                            </Button>
                        </Box>
                    </Flex>
                </Flex>
            </Flex>

            {/* Bottom Buttons */}
            <Flex mt={12} gap={4} flexWrap="wrap" justify="center" w="100%">
                <Button
                    leftIcon={<Icon as={RefreshCcw} />}
                    bg="gray.700"
                    color="white"
                    _hover={{ bg: 'gray.600' }}
                    onClick={() => {
                        setRegenerateType('CVV');
                        setIsRegenerateOpen(true);
                    }}
                >
                    Regenerate CVV
                </Button>
                <Button
                    leftIcon={<Icon as={KeyRound} />}
                    bg="gray.700"
                    color="white"
                    _hover={{ bg: 'gray.600' }}
                    onClick={() => {
                        setRegenerateType('PIN');
                        setIsRegenerateOpen(true);
                    }}
                >
                    Regenerate PIN
                </Button>
            </Flex>

            {/* Action Modal */}
            <ActionSuccessModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                title={modalProps.title}
                description={modalProps.description}
                badgeLabel={modalProps.badgeLabel}
                type={modalProps.type}
            />

            {/* Regenerate Modal */}
            <RegenerateCodeModal
                isOpen={isRegenerateOpen}
                onClose={() => setIsRegenerateOpen(false)}
                codeType={regenerateType}
            />
        </>
    );
}
