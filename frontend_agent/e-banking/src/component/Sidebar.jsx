// src/component/Sidebar.jsx
import {
    Box,
    Flex,
    Icon,
    Text,
    VStack,
    Divider,
    useColorModeValue
} from '@chakra-ui/react';
import {
    FiHome,
    FiUsers,
    FiCreditCard,
    FiDollarSign,
    FiMapPin,
    FiBell,
    FiUser,
    FiLock
} from 'react-icons/fi';
import { useLocation, useNavigate } from 'react-router-dom';

const navItems = [
    { label: 'Main Dashboard', icon: FiHome, path: '/' },
    { label: 'Users', icon: FiUsers, path: '/users' },
    { label: 'Cards', icon: FiCreditCard, path: '/cards' },
    { label: 'Transactions', icon: FiDollarSign, path: '/transactions' },
    { label: 'Travel Plan', icon: FiMapPin, path: '/travel' },
    { label: 'Notifications', icon: FiBell, path: '/notifications' },
    { label: 'Profile', icon: FiUser, path: '/profile' },
    { label: 'Sign In', icon: FiLock, path: '/signin' },
];

export default function Sidebar() {
    const location = useLocation();
    const navigate = useNavigate();

    const bg = useColorModeValue('white', '#18214a');
    const activeColor = useColorModeValue('black', 'white');
    const textColor = useColorModeValue('gray.500', 'gray.400');
    const iconColor = useColorModeValue('gray.500', 'gray.500');
    const dividerColor = useColorModeValue('gray.200', 'whiteAlpha.200');
    const hoverColor = useColorModeValue('black', 'white');

    return (
        <Box w="300px" h="100vh" position="fixed" bg={bg} px="32px" py="24px">
            <Text fontSize="24px" fontWeight="bold" pl="10" pt="8" mb="35px" color={activeColor}>
                HPS <Text as="span" fontWeight="normal">AGENT</Text>
            </Text>

            <Divider mb="40px" borderColor={dividerColor} />

            <VStack align="stretch" spacing="24px">
                {navItems.map((item) => {
                    const isActive = location.pathname === item.path;

                    return (
                        <Flex
                            key={item.label}
                            onClick={() => navigate(item.path)}
                            align="center"
                            fontWeight={isActive ? 'bold' : 'medium'}
                            fontSize="xl"
                            color={isActive ? activeColor : textColor}
                            gap="12px"
                            px="4px"
                            pr="10px"
                            cursor="pointer"
                            _hover={{ color: hoverColor, textDecoration: 'none' }}
                            position="relative"
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
                    );
                })}
            </VStack>
        </Box>
    );
}
