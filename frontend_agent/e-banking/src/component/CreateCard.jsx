import {
    Box,
    Flex,
    Icon,
    Text,
    Input,
    IconButton,
    VStack,
    HStack,
    Divider,
    useColorModeValue,
    Circle,
} from '@chakra-ui/react';
import { FaCcVisa, FaCcMastercard, FaCcAmex, FaPlus, FaTimes } from 'react-icons/fa';
import { useState } from 'react';

const cards = [
    {
        id: 'visa',
        label: 'Visa **** 8092',
        expires: 'Expires on 12/26',
        icon: FaCcVisa,
        logoColor: '#fff',
        darkBg: '#2a2f74',
        lightBg: '#e3e6ff',
    },
    {
        id: 'mastercard',
        label: 'Mastercard **** 8092',
        expires: 'Expires on 12/26',
        icon: FaCcMastercard,
        logoColor: '#FF5F00',
        darkBg: '#1c223e',
        lightBg: '#f6f8fc',
    },
    {
        id: 'amex',
        label: 'American Express **** 8092',
        expires: 'Expires on 12/26',
        icon: FaCcAmex,
        logoColor: '#2E77BB',
        darkBg: '#141f52',
        lightBg: '#edf2f7',
    },
];

export default function CreateCard() {
    const [selectedCardId, setSelectedCardId] = useState('visa');

    const isLight = useColorModeValue(true, false);
    const containerBg = useColorModeValue('white', '#141f52');
    const inputBg = useColorModeValue('gray.100', 'gray.800');
    const inputColor = useColorModeValue('gray.800', 'white');
    const labelColor = useColorModeValue('gray.600', 'gray.400');
    const sectionTitle = useColorModeValue('gray.800', 'white');
    const subTextColor = useColorModeValue('gray.500', 'gray.300');

    return (
        <Box bg={containerBg} p="6" borderRadius="20px" boxShadow="md">
            {/* Payment Methods */}
            <VStack spacing="3" align="stretch" mb="8">
                {cards.map((card) => {
                    const isSelected = selectedCardId === card.id;
                    const bgColor = isSelected
                        ? isLight
                            ? '#d1d9ff'
                            : card.darkBg
                        : isLight
                            ? card.lightBg
                            : card.darkBg;

                    return (
                        <Flex
                            key={card.id}
                            align="center"
                            justify="space-between"
                            bg={bgColor}
                            color={isLight ? 'gray.800' : 'white'}
                            px="4"
                            py="3"
                            borderRadius="md"
                            border={isSelected ? '2px solid #7551FF' : '1px solid transparent'}
                            cursor="pointer"
                            onClick={() => setSelectedCardId(card.id)}
                        >
                            <HStack spacing="4">
                                <Circle
                                    size="16px"
                                    border="2px solid"
                                    borderColor={isSelected ? '#7551FF' : 'gray.400'}
                                    bg={isSelected ? '#7551FF' : 'transparent'}
                                />
                                <Icon as={card.icon} boxSize="6" color={card.logoColor} />
                                <Box>
                                    <Text fontWeight="bold" fontSize="sm">
                                        {card.label}
                                    </Text>
                                    <Text fontSize="xs" color={subTextColor}>
                                        {card.expires}
                                    </Text>
                                </Box>
                            </HStack>
                            <IconButton
                                icon={<FaTimes />}
                                aria-label="Remove"
                                size="sm"
                                variant="ghost"
                                color={subTextColor}
                            />
                        </Flex>
                    );
                })}
                <Flex align="center" gap="2" pl="2" mt="2" color="gray.500" fontSize="sm" cursor="pointer">
                    <Icon as={FaPlus} />
                    <Text>Add a new payment method</Text>
                </Flex>
            </VStack>

            <Divider borderColor="gray.300" mb="6" />

            {/* Billing Address */}
            <Box>
                <Text fontSize="lg" fontWeight="bold" color={sectionTitle} mb="1">
                    Billing address
                </Text>
                <Text fontSize="sm" color={subTextColor} mb="6">
                    Lorem ipsum dolor sit amet consectetur adipiscing.
                </Text>

                <VStack spacing="4" align="stretch">
                    <Box>
                        <Text color={labelColor} fontSize="sm" mb="1">👤 Full name</Text>
                        <Input bg={inputBg} color={inputColor} placeholder="John Carter" />
                    </Box>

                    <Box>
                        <Text color={labelColor} fontSize="sm" mb="1">📍 Address</Text>
                        <Input bg={inputBg} color={inputColor} placeholder="601 4th St #103" />
                    </Box>

                    <Box>
                        <Text color={labelColor} fontSize="sm" mb="1">🌐 State</Text>
                        <Input bg={inputBg} color={inputColor} placeholder="Los Angeles" />
                    </Box>

                    <Box>
                        <Text color={labelColor} fontSize="sm" mb="1">📦 Zip code</Text>
                        <Input bg={inputBg} color={inputColor} placeholder="90001" />
                    </Box>
                </VStack>
            </Box>
        </Box>
    );
}
