import {
    Box,
    Button,
    Flex,
    Grid,
    Icon,
    Text,
    useColorModeValue,
} from '@chakra-ui/react';
import { AddIcon } from '@chakra-ui/icons';
import { PiUsersThreeFill } from 'react-icons/pi';         // more fun
import { BsStars } from 'react-icons/bs';                  // top users
import { IoPersonAddSharp } from 'react-icons/io5';        // new users
import { RiUserVoiceFill } from 'react-icons/ri';          // others

export default function StatisticCards({ onAddUserClick }) {
    const cardBg = useColorModeValue('white', '#141f52');

    return (
        <Box mb="40px">
            {/* Add User Button */}
            <Flex justify="flex-end" mb="24px">
                <Button
                    leftIcon={<AddIcon />}
                    bg={useColorModeValue('purple.100', 'purple.500')}
                    color={useColorModeValue('purple.800', 'white')}
                    _hover={{ bg: useColorModeValue('purple.200', 'purple.600') }}
                    onClick={onAddUserClick}
                >
                    Add User
                </Button>
            </Flex>

            {/* Statistic Cards */}
            <Grid
                templateColumns={{ base: '1fr', sm: 'repeat(2, 1fr)', xl: 'repeat(4, 1fr)' }}
                gap="20px"
            >
                <StatCard icon={PiUsersThreeFill} label="Total Users" value="250" color="#9F7AEA" />
                <StatCard icon={IoPersonAddSharp} label="New Users" value="15" color="#F6AD55" />
                <StatCard icon={BsStars} label="Top Users" value="200" color="#38B2AC" />
                <StatCard icon={RiUserVoiceFill} label="Other Users" value="35" color="#4299E1" />
            </Grid>
        </Box>
    );
}

function StatCard({ icon, label, value, color }) {
    const bg = useColorModeValue('white', '#141f52');
    const textColor = useColorModeValue('gray.800', 'white');
    const labelColor = useColorModeValue('gray.500', 'gray.400');

    return (
        <Box
            bg={bg}
            borderRadius="20px"
            p="20px"
            boxShadow="md"
        >
            <Flex direction="column" align="center" gap={3}>
                <Flex align="center" gap={3}>
                    <Icon as={icon} boxSize={6} color={color} />
                    <Text fontSize="md" color={labelColor}>{label}</Text>
                </Flex>
                <Text fontSize="2xl" fontWeight="bold" color={textColor}>
                    {value}
                </Text>
            </Flex>
        </Box>
    );
}
