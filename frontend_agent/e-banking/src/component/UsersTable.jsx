import {
    Badge,
    Box,
    Flex,
    IconButton,
    Input,
    InputGroup,
    InputLeftElement,
    Table,
    Tbody,
    Td,
    Text,
    Th,
    Thead,
    Tr,
    useColorModeValue,
} from '@chakra-ui/react';
import { FiChevronLeft, FiChevronRight, FiSearch, FiChevronRight as FiDetails } from 'react-icons/fi';
import { useState } from 'react';

const allUsers = [
    {
        name: 'Youssef Amrani',
        email: 'youssef.amrani@gmail.com',
        status: 'active',
        biometricEnabled: true,
        cardCount: 3,
        physicalCards: 2,
        virtualCards: 1,
    },
    {
        name: 'Sarah El Idrissi',
        email: 'sarah.idrissi@gmail.com',
        status: 'pending',
        biometricEnabled: false,
        cardCount: 1,
        physicalCards: 0,
        virtualCards: 1,
    },
    {
        name: 'Omar Benchekroun',
        email: 'omar.benchekroun@ebank.com',
        status: 'active',
        biometricEnabled: true,
        cardCount: 5,
        physicalCards: 3,
        virtualCards: 2,
    },
    {
        name: 'Fatima Zahra Lahlou',
        email: 'fatima.zahra@bank.ma',
        status: 'suspended',
        biometricEnabled: false,
        cardCount: 2,
        physicalCards: 1,
        virtualCards: 1,
    },
];

export default function UsersTable() {
    const [search, setSearch] = useState('');
    const bg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('black', 'white');
    const headerBg = useColorModeValue('gray.100', '#1e2a63');
    const nameColor = useColorModeValue('gray.800', 'white');
    const emailColor = useColorModeValue('gray.500', 'gray.300');
    const rowBg1 = useColorModeValue('white', '#1e2a63');
    const rowBg2 = useColorModeValue('gray.50', '#151c4a');

    const filteredUsers = allUsers.filter(user => {
        const searchTerm = search.trim().toLowerCase();
        if (!searchTerm) return true; // show all if empty

        const nameParts = user.name.toLowerCase().split(' ');
        return nameParts.some(part => part.startsWith(searchTerm));
    });

    return (
        <Box bg={bg} borderRadius="20px" p="24px" boxShadow="2xl" color={textColor}>
            <Flex justify="space-between" align="center" mb="20px" flexWrap="wrap" gap="12px">
                <Text fontSize="2xl" fontWeight="bold">👥 All Users</Text>

                <InputGroup maxW="300px">
                    <InputLeftElement pointerEvents="none" children={<FiSearch color="gray.400" />} />
                    <Input
                        placeholder="Search by first or middle name"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        borderRadius="full"
                        bg={useColorModeValue('white', '#0f1e4d')}
                        color={textColor}
                        _focus={{ borderColor: 'purple.400' }}
                    />
                </InputGroup>
            </Flex>

            <Box overflowX="auto" borderRadius="16px" overflow="hidden">
                <Table variant="unstyled" size="md">
                    <Thead>
                        <Tr bg={headerBg}>
                            {['Users', 'Status', 'Biometric', 'Cards', 'Physical', 'Virtual', 'Actions'].map((h, i) => (
                                <Th key={i} color="white" textAlign="center" fontSize="sm" letterSpacing="wide">
                                    {h}
                                </Th>
                            ))}
                        </Tr>
                    </Thead>
                    <Tbody>
                        {filteredUsers.length === 0 ? (
                            <Tr>
                                <Td colSpan={7} textAlign="center" py="40px">
                                    <Text fontSize="lg" fontWeight="medium" color="gray.400">
                                        🚫 No users found
                                    </Text>
                                </Td>
                            </Tr>
                        ) : (
                            filteredUsers.map((user, index) => {
                                const bgColor = index % 2 === 0 ? rowBg1 : rowBg2;
                                return (
                                    <Tr
                                        key={index}
                                        bg={bgColor}
                                        _hover={{ transform: 'scale(1.01)', boxShadow: 'md', transition: '0.2s ease' }}
                                    >
                                        <Td textAlign="center">
                                            <Box>
                                                <Text fontWeight="semibold" fontSize="md" color={nameColor}>{user.name}</Text>
                                                <Text fontSize="sm" color={emailColor}>{user.email}</Text>
                                            </Box>
                                        </Td>
                                        <Td textAlign="center">
                                            <Badge
                                                borderRadius="full"
                                                px="2"
                                                fontSize="0.8em"
                                                colorScheme={
                                                    user.status === 'active'
                                                        ? 'green'
                                                        : user.status === 'pending'
                                                            ? 'orange'
                                                            : 'red'
                                                }
                                            >
                                                {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                                            </Badge>
                                        </Td>
                                        <Td textAlign="center">
                                            <Badge
                                                borderRadius="full"
                                                px="2"
                                                colorScheme={user.biometricEnabled ? 'green' : 'red'}
                                                fontWeight="medium"
                                            >
                                                {user.biometricEnabled ? 'Activate' : 'Disactivate'}
                                            </Badge>
                                        </Td>
                                        <Td textAlign="center">
                                            <Badge colorScheme="blue" borderRadius="full" px="2">{user.cardCount}</Badge>
                                        </Td>
                                        <Td textAlign="center">
                                            <Badge colorScheme="purple" borderRadius="full" px="2">{user.physicalCards}</Badge>
                                        </Td>
                                        <Td textAlign="center">
                                            <Badge colorScheme="pink" borderRadius="full" px="2">{user.virtualCards}</Badge>
                                        </Td>
                                        <Td textAlign="center">
                                            <Flex justify="center">
                                                <IconButton
                                                    icon={<FiDetails />}
                                                    aria-label="Details"
                                                    size="sm"
                                                    variant="outline"
                                                    _hover={{ bg: 'purple.100', color: 'purple.800' }}
                                                />
                                            </Flex>
                                        </Td>
                                    </Tr>
                                );
                            })
                        )}
                    </Tbody>
                </Table>
            </Box>

            <Flex justify="space-between" align="center" mt="24px">
                <Text fontSize="sm" color="gray.400">1 - {filteredUsers.length} of {allUsers.length}</Text>
                <Flex align="center" gap="12px">
                    <Text fontSize="sm" color="gray.400">Rows per page:</Text>
                    <Text fontSize="sm" fontWeight="bold">10</Text>
                    <IconButton icon={<FiChevronLeft />} aria-label="Prev" size="sm" />
                    <IconButton icon={<FiChevronRight />} aria-label="Next" size="sm" />
                </Flex>
            </Flex>
        </Box>
    );
}
