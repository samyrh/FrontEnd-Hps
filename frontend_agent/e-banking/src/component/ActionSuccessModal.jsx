// src/component/ActionSuccessModal.jsx
import {
    Modal,
    ModalOverlay,
    ModalContent,
    ModalCloseButton,
    Box,
    Text,
    Flex,
    Icon,
    Badge,
    useColorModeValue,
} from '@chakra-ui/react';
import { FiCheckCircle, FiXCircle } from 'react-icons/fi';

export default function ActionSuccessModal({
                                               isOpen,
                                               onClose,
                                               title,
                                               description,
                                               badgeLabel,
                                               type = "success", // "success" or "error"
                                           }) {
    const isSuccess = type === "success";

    // Dynamic colors
    const accentBg = useColorModeValue(
        isSuccess ? "green.50" : "red.50",
        isSuccess ? "green.700" : "red.700"
    );
    const accentIconColor = useColorModeValue(
        isSuccess ? "green.500" : "red.500",
        isSuccess ? "green.100" : "red.100"
    );
    const titleColor = useColorModeValue(
        isSuccess ? "green.700" : "red.700",
        isSuccess ? "green.100" : "red.100"
    );
    const bodyBg = useColorModeValue("white", "#0B1437");
    const textColor = useColorModeValue("gray.600", "gray.300");
    const badgeBg = useColorModeValue(
        isSuccess ? "green.100" : "red.100",
        isSuccess ? "green.600" : "red.600"
    );
    const badgeText = useColorModeValue(
        isSuccess ? "green.700" : "red.700",
        "white"
    );

    return (
        <Modal isOpen={isOpen} onClose={onClose} isCentered size="sm">
            <ModalOverlay />
            <ModalContent
                borderRadius="16px"
                overflow="hidden"
                p={0}
                bg={bodyBg}
                boxShadow="0 8px 30px rgba(0,0,0,0.2)"
            >
                {/* Top accent */}
                <Flex
                    direction="column"
                    align="center"
                    justify="center"
                    bg={accentBg}
                    py={5}
                >
                    <Icon
                        as={isSuccess ? FiCheckCircle : FiXCircle}
                        boxSize={8}
                        color={accentIconColor}
                        mb={2}
                    />
                    <Text fontWeight="bold" fontSize="lg" color={titleColor}>
                        {title}
                    </Text>
                </Flex>

                <ModalCloseButton color={textColor} />

                {/* Body */}
                <Box py={5} px={6}>
                    <Text fontSize="sm" color={textColor} mb={3}>
                        {description}
                    </Text>
                    <Badge
                        bg={badgeBg}
                        color={badgeText}
                        fontSize="sm"
                        px={3}
                        py={1}
                        rounded="full"
                    >
                        {badgeLabel}
                    </Badge>
                </Box>
            </ModalContent>
        </Modal>
    );
}
