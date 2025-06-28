import React, { useState } from 'react';
import {
    Box, Table, Thead, Tbody, Tr, Th, Td,
    Input, Select, Button, Flex, Text,
    useColorModeValue
} from '@chakra-ui/react';
import { SearchIcon } from '@chakra-ui/icons';

// Mock data
const travelPlans = [
    { cardNumber: '•••• 4631', cardholder: 'Dianne R.', startDate: '03/15/2023', countries: 'France, Germany', status: 'In Review' },
    { cardNumber: '•••• 4631', cardholder: 'Jacob T.', startDate: '03/14/2023', countries: 'June 10 2023', status: 'Approved' },
    { cardNumber: '•••• 4631', cardholder: 'Jacob T.', startDate: '03/17/2023', countries: 'Oct 21 2023', status: 'Rejected' },
    { cardNumber: '•••• 4631', cardholder: 'France, Germany', startDate: '03/31/2023', countries: 'July 2023', status: 'In Review' },
    { cardNumber: '•••• 4631', cardholder: 'Appr T.', startDate: '04/11/2023', countries: 'May 20 2023', status: 'In Review' },
    { cardNumber: '•••• 4631', cardholder: 'Mexico, Brazil', startDate: '04/01/2023', countries: 'June 30 2023', status: 'In Review' },
];

const TravelPlansTable = () => {
    const [search, setSearch] = useState('');
    const [statusFilter, setStatusFilter] = useState('');

    // Color styles
    const bgContainer = useColorModeValue('#ffffff', '#18214a');
    const bgInput = useColorModeValue('#f9fafb', '#161d3a');
    const tableHeaderColor = useColorModeValue('#3a3a3a', '#cbd5e0');
    const hoverRowColor = useColorModeValue('#f1f5f9', '#1c2547');
    const titleColor = useColorModeValue('#0b1437', 'white');
    const boxShadowColor = useColorModeValue('rgba(0, 0, 0, 0.1)', 'rgba(0,0,0,0.3)');

    // Badge colors
    const inReviewBg = useColorModeValue('#ede9fe', '#3c366b');
    const inReviewColor = useColorModeValue('#5b21b6', '#d6bcfa');

    const approvedBg = useColorModeValue('#e6f4ea', '#2f5132');
    const approvedColor = useColorModeValue('#237d4a', '#a0f0c2');

    const rejectedBg = useColorModeValue('#fceaea', '#512f32');
    const rejectedColor = useColorModeValue('#a02b2b', '#f0a0a0');

    // Button styles
    const approveOutline = {
        border: '1px solid',
        borderColor: useColorModeValue('#c6f6d5', '#276749'),
        color: useColorModeValue('#276749', '#c6f6d5'),
        _hover: {
            bg: useColorModeValue('#e6f4ea', '#276749'),
            color: useColorModeValue('#276749', '#e6f4ea'),
        },
    };

    const rejectOutline = {
        border: '1px solid',
        borderColor: useColorModeValue('#fed7d7', '#822727'),
        color: useColorModeValue('#822727', '#fed7d7'),
        _hover: {
            bg: useColorModeValue('#fceaea', '#822727'),
            color: useColorModeValue('#822727', '#fceaea'),
        },
    };

    const filteredPlans = travelPlans.filter(plan =>
        (plan.cardholder.toLowerCase().includes(search.toLowerCase())) &&
        (statusFilter === '' || plan.status === statusFilter)
    );

    return (
        <Box
            p={8}
            bg={bgContainer}
            borderRadius="xl"
            boxShadow={`0 4px 20px ${boxShadowColor}`}
            transition="0.3s"
        >
            <Text fontSize="3xl" fontWeight="bold" mb={8} color={titleColor}>
                Travel Plans Management
            </Text>

            <Flex mb={8} gap={4} flexWrap="wrap">
                <Flex align="center" bg={bgInput} p={3} borderRadius="md" flex="1" minW="250px" boxShadow="sm">
                    <SearchIcon mr={2} color="gray.400" />
                    <Input
                        placeholder="Search by cardholder"
                        variant="unstyled"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </Flex>

                <Select
                    placeholder="All Statuses"
                    bg={bgInput}
                    border="none"
                    w="200px"
                    boxShadow="sm"
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                >
                    <option value="In Review">In Review</option>
                    <option value="Approved">Approved</option>
                    <option value="Rejected">Rejected</option>
                </Select>

                <Input
                    placeholder="End date"
                    type="date"
                    bg={bgInput}
                    border="none"
                    w="200px"
                    boxShadow="sm"
                />
            </Flex>

            <Table variant="unstyled" size="md">
                <Thead>
                    <Tr>
                        <Th color={tableHeaderColor}>Card</Th>
                        <Th color={tableHeaderColor}>Cardholder</Th>
                        <Th color={tableHeaderColor}>Start Date</Th>
                        <Th color={tableHeaderColor}>Countries</Th>
                        <Th color={tableHeaderColor}>Status</Th>
                        <Th color={tableHeaderColor}>Actions</Th>
                    </Tr>
                </Thead>
                <Tbody>
                    {filteredPlans.map((plan, idx) => {
                        const isActionDisabled = plan.status === 'Approved' || plan.status === 'Rejected';

                        const badgeBg =
                            plan.status === 'Approved'
                                ? approvedBg
                                : plan.status === 'Rejected'
                                    ? rejectedBg
                                    : inReviewBg;

                        const badgeColor =
                            plan.status === 'Approved'
                                ? approvedColor
                                : plan.status === 'Rejected'
                                    ? rejectedColor
                                    : inReviewColor;

                        return (
                            <Tr key={idx} _hover={{ bg: hoverRowColor, transition: "0.3s" }}>
                                <Td fontWeight="semibold">{plan.cardNumber}</Td>
                                <Td>{plan.cardholder}</Td>
                                <Td>{plan.startDate}</Td>
                                <Td>{plan.countries}</Td>
                                <Td>
                                    <Box
                                        px={3}
                                        py={0.5}
                                        borderRadius="full"
                                        fontWeight="semibold"
                                        fontSize="0.8em"
                                        bg={badgeBg}
                                        color={badgeColor}
                                        display="inline-block"
                                    >
                                        {plan.status}
                                    </Box>
                                </Td>
                                <Td>
                                    <Button
                                        size="sm"
                                        borderRadius="full"
                                        px={5}
                                        isDisabled={isActionDisabled}
                                        {...approveOutline}
                                        mr={2}
                                    >
                                        Approve
                                    </Button>

                                    <Button
                                        size="sm"
                                        borderRadius="full"
                                        px={5}
                                        isDisabled={isActionDisabled}
                                        {...rejectOutline}
                                    >
                                        Reject
                                    </Button>
                                </Td>
                            </Tr>
                        );
                    })}
                </Tbody>
            </Table>
        </Box>
    );
};

export default TravelPlansTable;
