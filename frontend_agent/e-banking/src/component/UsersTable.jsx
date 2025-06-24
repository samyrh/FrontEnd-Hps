import {
    Avatar,
    Badge,
    Box,
    Flex,
    IconButton,
    Table,
    Tbody,
    Td,
    Text,
    Th,
    Thead,
    Tr,
    useColorModeValue,
} from '@chakra-ui/react';
import { EditIcon, DeleteIcon } from '@chakra-ui/icons';
import { FiChevronLeft, FiChevronRight } from 'react-icons/fi';

const users = [
    {
        name: 'Youssef Amrani',
        email: 'youssef.amrani@gmail.com',
        phone: '+212 661-123456',
        country: 'Morocco',
        accountType: 'Premium',
        cardCount: 3,
        status: 'active',
        avatar: 'https://i.pravatar.cc/150?img=12',
    },
    {
        name: 'Sarah El Idrissi',
        email: 'sarah.idrissi@gmail.com',
        phone: '+212 662-654321',
        country: 'Morocco',
        accountType: 'Standard',
        cardCount: 1,
        status: 'pending',
        avatar: 'https://i.pravatar.cc/150?img=10',
    },
    {
        name: 'Omar Benchekroun',
        email: 'omar.benchekroun@ebank.com',
        phone: '+212 665-998877',
        country: 'France',
        accountType: 'VIP',
        cardCount: 5,
        status: 'active',
        avatar: 'https://i.pravatar.cc/150?img=14',
    },
    {
        name: 'Fatima Zahra Lahlou',
        email: 'fatima.zahra@bank.ma',
        phone: '+212 667-112233',
        country: 'Morocco',
        accountType: 'Standard',
        cardCount: 2,
        status: 'suspended',
        avatar: 'https://i.pravatar.cc/150?img=16',
    },
];

export default function UsersTable() {
    const bg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('black', 'white');
    const headerBg = useColorModeValue('gray.100', '#1e2a63');
    const nameColor = useColorModeValue('gray.800', 'white');
    const emailColor = useColorModeValue('gray.600', 'gray.300');
    const rowBg1 = useColorModeValue('white', '#1e2a63');
    const rowBg2 = useColorModeValue('gray.50', '#151c4a');

    return (
        <Box bg={bg} borderRadius="20px" p="24px" boxShadow="md" color={textColor}>
            <Flex justify="space-between" align="center" mb="20px">
                <Text fontSize="xl" fontWeight="bold">All Users</Text>
                <Text fontSize="sm" color="purple.300">1–10 of 256</Text>
            </Flex>

            <Box overflowX="auto" borderRadius="16px" overflow="hidden">
                <Table variant="unstyled" size="md">
                    <Thead>
                        <Tr bg={headerBg}>
                            <Th color="white">User</Th>
                            <Th color="white">Phone</Th>
                            <Th color="white">Country</Th>
                            <Th color="white">Account Type</Th>
                            <Th color="white">Cards</Th>
                            <Th color="white">Status</Th>
                            <Th color="white" textAlign="center">Actions</Th>
                        </Tr>
                    </Thead>
                    <Tbody>
                        {users.map((user, index) => {
                            const bgColor = index % 2 === 0 ? rowBg1 : rowBg2;
                            return (
                                <Tr key={index} bg={bgColor}>
                                    <Td>
                                        <Flex align="center" gap="12px">
                                            <Avatar size="sm" name={user.name} src={user.avatar} />
                                            <Box>
                                                <Text fontWeight="bold" color={nameColor}>{user.name}</Text>
                                                <Text fontSize="sm" color={emailColor}>{user.email}</Text>
                                            </Box>
                                        </Flex>
                                    </Td>
                                    <Td>{user.phone}</Td>
                                    <Td>{user.country}</Td>
                                    <Td>
                                        <Badge
                                            colorScheme={
                                                user.accountType === 'VIP'
                                                    ? 'green'
                                                    : user.accountType === 'Premium'
                                                        ? 'purple'
                                                        : 'gray'
                                            }
                                            variant="subtle"
                                            borderRadius="full"
                                            px="2"
                                        >
                                            {user.accountType}
                                        </Badge>
                                    </Td>
                                    <Td>
                                        <Badge colorScheme="blue" borderRadius="full" px="2">
                                            {user.cardCount}
                                        </Badge>
                                    </Td>
                                    <Td>
                                        <Badge
                                            colorScheme={
                                                user.status === 'active'
                                                    ? 'green'
                                                    : user.status === 'pending'
                                                        ? 'orange'
                                                        : 'red'
                                            }
                                            borderRadius="full"
                                            px="2"
                                        >
                                            {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                                        </Badge>
                                    </Td>
                                    <Td>
                                        <Flex justify="center" gap="8px">
                                            <IconButton icon={<EditIcon />} aria-label="Edit" size="sm" />
                                            <IconButton icon={<DeleteIcon />} aria-label="Delete" size="sm" />
                                            <IconButton icon={<FiChevronRight />} aria-label="More Details" size="sm" variant="outline" />
                                        </Flex>
                                    </Td>
                                </Tr>
                            );
                        })}
                    </Tbody>
                </Table>
            </Box>

            <Flex justify="space-between" align="center" mt="24px">
                <Text fontSize="sm" color="gray.400">1 - 10 of 460</Text>
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
