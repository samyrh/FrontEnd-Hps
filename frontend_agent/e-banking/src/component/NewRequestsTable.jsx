// src/component/NewRequestsTable.jsx
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
    useDisclosure,
} from '@chakra-ui/react';
import { useState } from 'react';
import RequestModal from './RequestModal';

const requestData = [
    {
        id: 1,
        number: '6645 1233-5517',
        type: 'Virtual',
        status: 'Active',
        request: 'New Card',
    },
    {
        id: 2,
        number: '4071 4208 8022',
        type: 'Physical',
        status: 'Temporarily blocked',
        request: 'New Card',
    },
    {
        id: 3,
        number: '5740 1566 0056',
        type: 'Virtual',
        status: 'Fraud blocked',
        request: 'New Card',
    },
];

const statusColor = {
    Active: 'green',
    'Temporarily blocked': 'orange',
    'Fraud blocked': 'purple',
};

export default function NewRequestsTable() {
    const cardBg = useColorModeValue('white', '#18214a');
    const textColor = useColorModeValue('#1A202C', 'white');
    const { isOpen, onOpen, onClose } = useDisclosure();
    const [selectedCard, setSelectedCard] = useState(null);
    const [action, setAction] = useState('');

    const handleAction = (card, actionType) => {
        setSelectedCard(card);
        setAction(actionType);
        onOpen();
    };

    return (
        <>
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
                            <Th color={textColor}>Request</Th>
                            <Th color={textColor}>Actions</Th>
                        </Tr>
                    </Thead>
                    <Tbody>
                        {requestData.map((card) => (
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
                                <Td>
                                    <Badge
                                        colorScheme="blue"
                                        px={3}
                                        py={1}
                                        rounded="md"
                                        fontSize="sm"
                                    >
                                        {card.request}
                                    </Badge>
                                </Td>
                                <Td>
                                    <Button
                                        variant="outline"
                                        colorScheme="green"
                                        size="sm"
                                        borderRadius="full"
                                        px={4}
                                        mr={2}
                                        onClick={() => handleAction(card, 'approve')}
                                    >
                                        Approve
                                    </Button>
                                    <Button
                                        variant="outline"
                                        colorScheme="red"
                                        size="sm"
                                        borderRadius="full"
                                        px={4}
                                        onClick={() => handleAction(card, 'reject')}
                                    >
                                        Reject
                                    </Button>
                                </Td>
                            </Tr>
                        ))}
                    </Tbody>
                </Table>
            </Box>

            {/* Modal */}
            <RequestModal
                isOpen={isOpen}
                onClose={onClose}
                card={selectedCard}
                action={action}
            />
        </>
    );
}
