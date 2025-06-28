// src/component/Notif.jsx
import { Box, Flex, Text, Badge, useColorModeValue } from '@chakra-ui/react';

export default function Notif({ title, description, date, type }) {
    const cardBg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('black', 'gray.100');

    // Map type to a color scheme
    const badgeColors = {
        Alerts: 'red',
        Transactions: 'green',
        'Travel Plans': 'yellow',
        All: 'blue',
    };

    return (
        <Box
            bg={cardBg}
            p={4}
            borderRadius="lg"
            boxShadow="sm"
            _hover={{ boxShadow: 'md', transform: 'translateY(-2px)' }}
            transition="all 0.2s"
        >
            <Flex justify="space-between" align="center" mb={2}>
                <Text fontWeight="bold" color={textColor}>
                    {title}
                </Text>
                <Badge colorScheme={badgeColors[type] || 'blue'}>
                    {type}
                </Badge>
            </Flex>
            <Text fontSize="sm" color="gray.300" mb={2}>
                {description}
            </Text>
            <Text fontSize="xs" color="gray.500">
                {date}
            </Text>
        </Box>
    );
}
