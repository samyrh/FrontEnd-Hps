// src/component/Filter.jsx
import { Flex, Button, Icon, useColorModeValue } from '@chakra-ui/react';
import { Bell, CreditCard, Plane, List } from 'lucide-react';

const filters = [
    { label: 'All', icon: List, color: 'blue.400' },
    { label: 'Alerts', icon: Bell, color: 'red.400' },
    { label: 'Transactions', icon: CreditCard, color: 'green.400' },
    { label: 'Travel Plans', icon: Plane, color: 'yellow.400' },
];

export default function Filter({ activeFilter, setActiveFilter }) {
    // Define colors for light and dark modes
    const activeBg = useColorModeValue('white', '#141f52');
    const inactiveBg = useColorModeValue('white', '#0b1437');
    const activeText = useColorModeValue('black', 'white');
    const inactiveText = useColorModeValue('gray.700', 'gray.300');

    return (
        <Flex gap={3} mb={6} flexWrap="wrap">
            {filters.map((filter) => (
                <Button
                    key={filter.label}
                    bg={activeFilter === filter.label ? activeBg : inactiveBg}
                    color={activeFilter === filter.label ? activeText : inactiveText}
                    _hover={{
                        bg: activeBg,
                        color: activeText,
                    }}
                    boxShadow="sm"
                    borderRadius="md"
                    px={4}
                    py={2}
                    onClick={() => setActiveFilter(filter.label)}
                    transition="all 0.2s"
                    leftIcon={
                        <Icon
                            as={filter.icon}
                            boxSize={4}
                            color={filter.color}
                        />
                    }
                >
                    {filter.label}
                </Button>
            ))}
        </Flex>
    );
}
