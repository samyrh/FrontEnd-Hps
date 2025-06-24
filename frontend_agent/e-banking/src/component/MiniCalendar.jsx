// src/component/MiniCalendar.jsx
import {
    Box,
    Flex,
    Text,
    SimpleGrid,
    IconButton,
    useColorModeValue,
} from '@chakra-ui/react';
import { ChevronLeftIcon, ChevronRightIcon } from '@chakra-ui/icons';

export default function MiniCalendar() {
    const bgColor = useColorModeValue('white', '#141f52');
    const titleColor = useColorModeValue('black', 'white');
    const headerColor = useColorModeValue('gray.500', 'white');
    const dayColor = useColorModeValue('gray.600', 'white');

    return (
        <Box
            bg={bgColor}
            p="24px"
            borderRadius="20px"
            boxShadow="0 4px 12px rgba(0, 0, 0, 0.06)"
            w="100%"
            textAlign="center"
        >
            <Flex justify="space-between" align="center" mb="16px">
                <IconButton icon={<ChevronLeftIcon />} size="sm" aria-label="prev" />
                <Text fontSize="lg" fontWeight="bold" color={titleColor}>
                    mai 2025
                </Text>
                <IconButton icon={<ChevronRightIcon />} size="sm" aria-label="next" />
            </Flex>

            <SimpleGrid
                columns={7}
                spacing="8px"
                textAlign="center"
                fontWeight="bold"
                color={headerColor}
                mb="8px"
            >
                {['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'].map((d, i) => (
                    <Text key={i}>{d}</Text>
                ))}
            </SimpleGrid>

            <SimpleGrid columns={7} spacing="8px">
                {Array.from({ length: 35 }, (_, i) => {
                    const day = i - 1;
                    const isToday = day === 30;
                    return (
                        <Box
                            key={i}
                            bg={isToday ? 'purple.500' : 'transparent'}
                            color={isToday ? 'white' : dayColor}
                            borderRadius="10px"
                            py="6px"
                        >
                            {day > 0 && day <= 31 ? day : ''}
                        </Box>
                    );
                })}
            </SimpleGrid>
        </Box>
    );
}
