import React, { useState } from 'react';
import {
    Box,
    Flex,
    Text,
    SimpleGrid,
    IconButton,
    useColorModeValue,
} from '@chakra-ui/react';
import { ChevronLeftIcon, ChevronRightIcon } from '@chakra-ui/icons';

// French month names
const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
];

export default function MiniCalendar() {
    const today = new Date();
    const [currentMonth, setCurrentMonth] = useState(today.getMonth());
    const [currentYear, setCurrentYear] = useState(today.getFullYear());

    const bgColor = useColorModeValue('white', '#141f52');
    const titleColor = useColorModeValue('black', 'white');
    const headerColor = useColorModeValue('gray.500', 'white');
    const dayColor = useColorModeValue('gray.600', 'white');

    const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
    const firstDayIndex = new Date(currentYear, currentMonth, 1).getDay(); // 0=Sunday
    const startIndex = (firstDayIndex + 6) % 7; // Convert Sunday=0 to Sunday=6

    const handlePrev = () => {
        if (currentMonth === 0) {
            setCurrentMonth(11);
            setCurrentYear(currentYear - 1);
        } else {
            setCurrentMonth(currentMonth - 1);
        }
    };

    const handleNext = () => {
        if (currentMonth === 11) {
            setCurrentMonth(0);
            setCurrentYear(currentYear + 1);
        } else {
            setCurrentMonth(currentMonth + 1);
        }
    };

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
                <IconButton icon={<ChevronLeftIcon />} size="sm" aria-label="prev" onClick={handlePrev} />
                <Text fontSize="lg" fontWeight="bold" color={titleColor}>
                    {months[currentMonth]} {currentYear}
                </Text>
                <IconButton icon={<ChevronRightIcon />} size="sm" aria-label="next" onClick={handleNext} />
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
                {Array.from({ length: startIndex }).map((_, i) => (
                    <Box key={`empty-${i}`} />
                ))}
                {Array.from({ length: daysInMonth }, (_, i) => {
                    const dayNumber = i + 1;
                    const isToday =
                        dayNumber === today.getDate() &&
                        currentMonth === today.getMonth() &&
                        currentYear === today.getFullYear();

                    return (
                        <Box
                            key={dayNumber}
                            bg={isToday ? 'purple.500' : 'transparent'}
                            color={isToday ? 'white' : dayColor}
                            borderRadius="10px"
                            py="6px"
                        >
                            {dayNumber}
                        </Box>
                    );
                })}
            </SimpleGrid>
        </Box>
    );
}
