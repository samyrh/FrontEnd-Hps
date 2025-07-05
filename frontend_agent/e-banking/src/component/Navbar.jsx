// src/component/Navbar.jsx
import React from 'react';
import PropTypes from 'prop-types';
import {
    Box,
    Breadcrumb,
    BreadcrumbItem,
    BreadcrumbLink,
    Flex,
    Text,
    Input,
    InputGroup,
    InputLeftElement,
    useColorModeValue,
    IconButton,
    Avatar,
    useColorMode,
} from '@chakra-ui/react';
import {
    SearchIcon,
    BellIcon,
    InfoOutlineIcon,
    SunIcon,
    MoonIcon,
} from '@chakra-ui/icons';
import { useNavigate } from 'react-router-dom'; // ✅ Import useNavigate

const SearchBar = () => {
    const placeholderColor = useColorModeValue('gray.500', 'whiteAlpha.500');
    const textColor = useColorModeValue('gray.700', 'whiteAlpha.900');

    return (
        <InputGroup w="180px">
            <InputLeftElement pointerEvents="none">
                <SearchIcon color={placeholderColor} w="15px" h="15px" />
            </InputLeftElement>
            <Input
                variant="unstyled"
                fontSize="sm"
                color={textColor}
                placeholder="Search..."
                _placeholder={{ color: placeholderColor }}
                pl="8"
                py="1.5"
            />
        </InputGroup>
    );
};

export default function Navbar({ brandText }) {
    const { colorMode, toggleColorMode } = useColorMode();
    const navigate = useNavigate(); // ✅ Initialize navigate

    const navbarBg = useColorModeValue('rgba(255, 255, 255, 0.25)', 'rgba(11, 20, 55, 0.4)');
    const mainText = useColorModeValue('gray.800', 'white');
    const secondaryText = useColorModeValue('gray.600', 'whiteAlpha.700');
    const iconColor = useColorModeValue('gray.700', 'whiteAlpha.800');
    const searchBg = useColorModeValue('#F4F7FE', '#0b1437');
    const containerBg = useColorModeValue('rgba(255,255,255,0.3)', 'rgba(255,255,255,0.05)');

    return (
        <Box
            position="fixed"
            top="20px"
            left="360px"
            right="20px"
            zIndex="1000"
            bg={navbarBg}
            backdropFilter="blur(16px)"
            borderRadius="16px"
            boxShadow="0 8px 32px rgba(0, 0, 0, 0.1)" // glass-style shadow
            px="24px"
            h="120px"
        >
            <Flex h="100%" justifyContent="space-between" alignItems="center">
                {/* Left Side: Breadcrumb and Title */}
                <Box>
                    <Breadcrumb>
                        <BreadcrumbItem>
                            <BreadcrumbLink color={secondaryText} fontSize="lg">
                                Pages
                            </BreadcrumbLink>
                        </BreadcrumbItem>
                        <BreadcrumbItem>
                            <BreadcrumbLink color={secondaryText} fontSize="lg">
                                {brandText}
                            </BreadcrumbLink>
                        </BreadcrumbItem>
                    </Breadcrumb>

                    <Text fontSize="3xl" fontWeight="bold" color={mainText}>
                        {brandText}
                    </Text>
                </Box>

                {/* Right Side: Search + Icons */}
                <Flex
                    borderRadius="full"
                    bg={containerBg}
                    px="15px"
                    py="25px"
                    align="center"
                    gap="6px"
                    h="80px"
                >
                    <Box
                        bg={searchBg}
                        px="20px"
                        py="10px"
                        borderRadius="full"
                    >
                        <SearchBar />
                    </Box>

                    <IconButton
                        aria-label="Notifications"
                        icon={<BellIcon boxSize={5} />}
                        variant="ghost"
                        color={iconColor}
                        size="sm"
                        onClick={() => navigate("/notifications")} // ✅ Navigate to notifications
                    />
                    <IconButton
                        aria-label="Info"
                        icon={<InfoOutlineIcon boxSize={5} />}
                        variant="ghost"
                        color={iconColor}
                        size="sm"
                    />
                    <IconButton
                        aria-label="Toggle Theme"
                        boxSize={5}
                        icon={colorMode === 'light' ? <MoonIcon /> : <SunIcon />}
                        variant="ghost"
                        color={iconColor}
                        size="sm"
                        onClick={toggleColorMode}
                    />
                    <Avatar name="Nada" src="https://i.pravatar.cc/150?img=47" size="md" />
                </Flex>
            </Flex>
        </Box>
    );
}

Navbar.propTypes = {
    brandText: PropTypes.string.isRequired,
};
