// src/component/ComplexTable.jsx
import {
    Box,
    Flex,
    Text,
    Table,
    Thead,
    Tbody,
    Tr,
    Th,
    Td,
    IconButton,
    useColorModeValue,
} from '@chakra-ui/react';
import { FiMoreVertical } from 'react-icons/fi';

export default function ComplexTable() {
    const bg = useColorModeValue('white', '#141f52');
    const headingColor = useColorModeValue('gray.500', 'white');
    const textColor = useColorModeValue('black', 'white');
    const iconColor = useColorModeValue('gray.800', 'white');

    const data = [
        { name: 'Marketplace', status: 'Approved', color: 'green.400', date: '24.Jan.2021' },
        { name: 'Marketplace', status: 'Disable', color: 'red.400', date: '30.Dec.2021' },
        { name: 'Marketplace', status: 'Error', color: 'orange.400', date: '20.May.2021' },
        { name: 'Marketplace', status: 'Approved', color: 'green.400', date: '12.Jul.2021' },
    ];

    return (
        <Box
            bg={bg}
            p="24px"
            borderRadius="20px"
            boxShadow="0 4px 12px rgba(0, 0, 0, 0.06)"
            w="100%"
        >
            <Flex justify="space-between" mb="16px">
                <Text fontSize="lg" fontWeight="bold" color={textColor}>
                    Complex Table
                </Text>
                <IconButton
                    icon={<FiMoreVertical />}
                    size="sm"
                    aria-label="options"
                    color={iconColor}
                    bg="transparent"
                    _hover={{ bg: 'transparent' }}
                />
            </Flex>
            <Table variant="simple">
                <Thead>
                    <Tr>
                        <Th color={headingColor}>NAME</Th>
                        <Th color={headingColor}>STATUS</Th>
                        <Th color={headingColor}>DATE</Th>
                    </Tr>
                </Thead>
                <Tbody>
                    {data.map((row, i) => (
                        <Tr key={i}>
                            <Td>
                                <Text color={textColor}>{row.name}</Text>
                            </Td>
                            <Td>
                                <Flex align="center" gap="8px">
                                    <Box w="8px" h="8px" borderRadius="full" bg={row.color}></Box>
                                    <Text color={textColor}>{row.status}</Text>
                                </Flex>
                            </Td>
                            <Td>
                                <Text fontWeight="bold" color={textColor}>
                                    {row.date}
                                </Text>
                            </Td>
                        </Tr>
                    ))}
                </Tbody>
            </Table>
        </Box>
    );
}
