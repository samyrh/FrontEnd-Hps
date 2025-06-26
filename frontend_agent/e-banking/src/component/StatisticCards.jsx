import {
    Box,
    Button,
    Flex,
    Grid,
    Icon,
    IconButton,
    Text,
    useColorModeValue,
} from '@chakra-ui/react';
import { AddIcon, ChevronDownIcon } from '@chakra-ui/icons';
import { FaUsers, FaUserPlus, FaHeart, FaCircle } from 'react-icons/fa';

export default function StatisticCards({ onAddUserClick }) {
    const cardBg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('black', 'white');

    return (
        <Box mb="40px">
            {/* Add User Button */}
            <Flex justify="flex-end" mb="24px">
                <Button
                    leftIcon={<AddIcon />}
                    bg={useColorModeValue('purple.100', 'purple.500')}
                    color={useColorModeValue('purple.800', 'white')}
                    _hover={{ bg: useColorModeValue('purple.200', 'purple.600') }}
                    onClick={onAddUserClick} // 🔁 trigger the parent action
                >
                    Add User
                </Button>
            </Flex>

            {/* Statistic Cards */}
            <Grid
                templateColumns={{ base: '1fr', sm: 'repeat(2, 1fr)', xl: 'repeat(4, 1fr)' }}
                gap="20px"
            >
                <StatCard icon={FaUsers} label="Total Users" value="250" color="#9F7AEA" />
                <StatCard icon={FaUserPlus} label="New Users" value="15" color="#F6AD55" />
                <StatCard icon={FaHeart} label="Top Users" value="200" color="#38B2AC" />
                <StatCard icon={FaCircle} label="Other Users" value="35" color="#4299E1" />
            </Grid>
        </Box>
    );
}

function StatCard({ icon, label, value, color }) {
    return (
        <Box
            bg={useColorModeValue('white', '#141f52')}
            borderRadius="20px"
            p="20px"
            boxShadow="md"
        >
            <Flex align="center" justify="space-between">
                <Flex align="center" gap="12px">
                    <Icon as={icon} boxSize={6} color={color} />
                    <Box>
                        <Text fontSize="md" color="gray.400">{label}</Text>
                        <Text fontSize="lg" fontWeight="bold" color={useColorModeValue('gray.800', 'white')}>
                            {value}
                        </Text>
                    </Box>
                </Flex>
                <IconButton
                    icon={<ChevronDownIcon />}
                    aria-label="More"
                    variant="ghost"
                    color="gray.400"
                />
            </Flex>
        </Box>
    );
}
