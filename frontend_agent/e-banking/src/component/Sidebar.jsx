import {
    Box,
    Flex,
    Icon,
    Link,
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

const navItems = [
    { label: 'Main Dashboard', icon: FiHome },
    { label: 'Users', icon: FiUsers },
    { label: 'Cards', icon: FiCreditCard },
    { label: 'Travel Plan', icon: FiMapPin },
    { label: 'Notifications', icon: FiBell },
    { label: 'Profile', icon: FiUser },
    { label: 'Sign In', icon: FiLock },
];

export default function Sidebar() {
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
                    const isActive = item.label === 'Main Dashboard'; // Replace this with actual active route logic

                    return (
                        <Link
                            key={item.label}
                            position="relative"
                            display="flex"
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
                        </Link>
                    );
                })}
            </VStack>
        </Box>
    );
}
