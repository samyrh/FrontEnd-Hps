// src/component/Sidebar.jsx
import {
    Box,
    Flex,
    Icon,
    Text,
    VStack,
    Divider,
    useColorModeValue,
} from '@chakra-ui/react';
import {
    FiHome,
    FiUsers,
    FiCreditCard,
    FiMapPin,
    FiBell,
    FiUser,
    FiLock,
} from 'react-icons/fi';
import { Link, useLocation } from 'react-router-dom';

const navItems = [
    { label: 'Main Dashboard', icon: FiHome, to: '/' }, // This leads to MainDashboard
    { label: 'Users', icon: FiUsers, to: '/users' },     // You must define this route below
    { label: 'Cards', icon: FiCreditCard, to: '/cards' },
    { label: 'Travel Plan', icon: FiMapPin, to: '/travel-plan' },
    { label: 'Notifications', icon: FiBell, to: '/notifications' },
    { label: 'Profile', icon: FiUser, to: '/profile' },
    { label: 'Sign In', icon: FiLock, to: '/signin' },
];


export default function Sidebar() {
    const location = useLocation();
    const bg = useColorModeValue('white', '#18214a');
    const activeColor = useColorModeValue('black', 'white');
    const textColor = useColorModeValue('gray.500', 'gray.400');
    const iconColor = useColorModeValue('gray.500', 'gray.500');
    const dividerColor = useColorModeValue('gray.200', 'whiteAlpha.200');
    const hoverColor = useColorModeValue('black', 'white');

    return (
        <Box
            w="340px"
            h="100vh"
            position="fixed"
            bg={bg}
            px="32px"
            py="24px"
        >
            <Box pl="10" pt="8" mb="35px">
                <Text fontSize="24px" fontWeight="bold" color={activeColor}>
                    HPS <Text as="span" fontWeight="normal">AGENT</Text>
                </Text>
            </Box>

            <Divider mb="40px" borderColor={dividerColor} />

            <VStack align="stretch" spacing="24px">
                {navItems.map((item) => {
                    const isActive = location.pathname.startsWith(item.to);

                    return (
                        <Link
                            to={item.to}
                            key={item.label}
                            style={{ textDecoration: 'none' }}
                        >
                            <Flex
                                position="relative"
                                alignItems="center"
                                fontWeight={isActive ? 'bold' : 'medium'}
                                fontSize="xl"
                                color={isActive ? activeColor : textColor}
                                gap="12px"
                                px="4px"
                                pr="10px"
                                _hover={{
                                    color: hoverColor,
                                    textDecoration: 'none',
                                }}
                            >
                                <Icon as={item.icon} boxSize={5} color={isActive ? '#7551FF' : iconColor} />
                                {item.label}
                                {isActive && (
                                    <Box
                                        position="absolute"
                                        right="0"
                                        top="50%"
                                        transform="translateY(-50%)"
                                        w="4px"
                                        h="24px"
                                        bg="#7551FF"
                                        borderRadius="full"
                                    />
                                )}
                            </Flex>
                        </Link>
                    );
                })}
            </VStack>
        </Box>
    );
}
