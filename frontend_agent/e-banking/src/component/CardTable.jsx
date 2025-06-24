import {
    Box,
    Table,
    Thead,
    Tbody,
    Tr,
    Th,
    Td,
    Badge,
    Button,
    useColorModeValue,
} from '@chakra-ui/react';
import { useNavigate } from 'react-router-dom'; // or use useRouter from go-router

const cardData = [
    {
        id: 1,
        number: '6645 1233-5517',
        type: 'Virtual',
        status: 'Active',
        cvv: '*****',
        expiry: '08/25',
    },
    {
        id: 2,
        number: '4071 4208 8022',
        type: 'Physical',
        status: 'Temporarily blocked',
        cvv: '*****',
        expiry: '08/25',
    },
    {
        id: 3,
        number: '5740 1566 0056',
        type: 'Virtual',
        status: 'Active',
        cvv: '*****',
        expiry: '08/25',
    },
    {
        id: 4,
        number: '4043 1234 5678',
        type: 'Physical',
        status: 'Fraud blocked',
        cvv: '*****',
        expiry: '08/25',
    },
    {
        id: 5,
        number: '7379 8812 9367',
        type: 'Damaged',
        status: 'Damaged',
        cvv: '*****',
        expiry: '08/25',
    },
    {
        id: 6,
        number: '1223 4567 8900',
        type: 'Closed',
        status: 'Closed',
        cvv: '*****',
        expiry: '08/25',
    },
];

const statusColor = {
    Active: 'green',
    'Temporarily blocked': 'orange',
    'Fraud blocked': 'purple',
    Damaged: 'blue',
    Closed: 'gray',
};

export default function CardTable() {
    const cardBg = useColorModeValue('white', '#18214a');
    const textColor = useColorModeValue('#1A202C', 'white');
    const navigate = useNavigate(); // for navigation

    const handleViewDetails = (id) => {
        navigate(`/card-details/${id}`);
    };

    return (
        <Box
            mt={10}
            mb={20}
            bg={cardBg}
            borderRadius="20px"
            px={{ base: 4, md: 6 }}
            py={6}
            overflowX="auto"
            boxShadow="md"
            maxW="1200px"
            mx="auto"
        >
            <Table variant="simple">
                <Thead>
                    <Tr>
                        <Th color={textColor}>Card Number</Th>
                        <Th color={textColor}>Type</Th>
                        <Th color={textColor}>Status</Th>
                        <Th color={textColor}>CVV</Th>
                        <Th color={textColor}>Expiration Date</Th>
                        <Th color={textColor}>Actions</Th>
                    </Tr>
                </Thead>
                <Tbody>
                    {cardData.map((card) => (
                        <Tr key={card.id}>
                            <Td color={textColor}>{card.number}</Td>
                            <Td>
                                <Badge
                                    colorScheme={
                                        card.type === 'Virtual'
                                            ? 'cyan'
                                            : card.type === 'Physical'
                                                ? 'orange'
                                                : 'gray'
                                    }
                                    variant="subtle"
                                    px={2}
                                    py={0.5}
                                    rounded="md"
                                >
                                    {card.type}
                                </Badge>
                            </Td>
                            <Td>
                                <Badge
                                    colorScheme={statusColor[card.status] || 'gray'}
                                    px={3}
                                    py={1}
                                    rounded="md"
                                    fontSize="sm"
                                >
                                    {card.status}
                                </Badge>
                            </Td>
                            <Td color={textColor}>{card.cvv}</Td>
                            <Td color={textColor}>{card.expiry}</Td>
                            <Td>
                                <Button
                                    colorScheme="blue"
                                    size="sm"
                                    onClick={() => handleViewDetails(card.id)}
                                >
                                    View
                                </Button>
                            </Td>
                        </Tr>
                    ))}
                </Tbody>
            </Table>
        </Box>
    );
}
