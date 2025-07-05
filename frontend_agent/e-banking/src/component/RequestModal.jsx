// src/component/RequestModal.jsx
import {
    Modal,
    ModalOverlay,
    ModalContent,
    ModalCloseButton,
    Box,
    Text,
    Badge,
    Stack,
    Flex,
    Icon,
    useColorModeValue,
} from '@chakra-ui/react';
import { FiCheckCircle, FiXCircle } from 'react-icons/fi';

export default function RequestModal({ isOpen, onClose, card, action }) {
    // Always call hooks first
    const modalBg = useColorModeValue('white', '#0B1437');
    const textPrimary = useColorModeValue('gray.800', 'white');
    const textSecondary = useColorModeValue('gray.500', 'gray.300');
    const labelColor = useColorModeValue('gray.500', 'gray.400');
    const closeColor = useColorModeValue('gray.600', 'gray.300');

    if (!card) return null;

    const isApprove = action === 'approve';
    const icon = isApprove ? FiCheckCircle : FiXCircle;
    const iconBg = isApprove ? 'green.100' : 'red.100';
    const iconColor = isApprove ? 'green.500' : 'red.500';

    return (
        <Modal isOpen={isOpen} onClose={onClose} size="sm" isCentered>
            <ModalOverlay />
            <ModalContent
                bg={modalBg}
                borderRadius="16px"
                boxShadow="0 8px 40px rgba(0,0,0,0.2)"
                p={0}
                overflow="hidden"
            >
                {/* Icon */}
                <Flex justify="center" mt={6}>
                    <Flex
                        bg={iconBg}
                        borderRadius="full"
                        p={3}
                        align="center"
                        justify="center"
                    >
                        <Icon as={icon} boxSize={6} color={iconColor} />
                    </Flex>
                </Flex>

                {/* Title */}
                <Flex direction="column" align="center" mt={3} mb={1} px={4}>
                    <Text fontWeight="bold" fontSize="lg" color={textPrimary}>
                        {isApprove ? 'Request Approved' : 'Request Rejected'}
                    </Text>
                    <Text fontSize="sm" color={textSecondary}>
                        Review the request information below.
                    </Text>
                </Flex>

                {/* Details */}
                <Box mt={4} px={6} py={5}>
                    <Stack spacing={4}>
                        {/* Card Number */}
                        <Box>
                            <Text fontSize="xs" color={labelColor} mb={1}>
                                CARD NUMBER
                            </Text>
                            <Text fontSize="md" fontWeight="medium" color={textPrimary}>
                                {card.number}
                            </Text>
                        </Box>

                        {/* Status */}
                        <Box>
                            <Text fontSize="xs" color={labelColor} mb={1}>
                                STATUS
                            </Text>
                            <Badge
                                bg="green.50"
                                color="green.600"
                                px={3}
                                py={1}
                                rounded="full"
                                fontSize="sm"
                            >
                                {card.status}
                            </Badge>
                        </Box>

                        {/* Request */}
                        <Box>
                            <Text fontSize="xs" color={labelColor} mb={1}>
                                REQUEST
                            </Text>
                            <Badge
                                bg="blue.50"
                                color="blue.600"
                                px={3}
                                py={1}
                                rounded="full"
                                fontSize="sm"
                            >
                                {card.request}
                            </Badge>
                        </Box>

                        {/* Action */}
                        <Box>
                            <Text fontSize="xs" color={labelColor} mb={1}>
                                ACTION
                            </Text>
                            <Badge
                                bg={isApprove ? 'green.50' : 'red.50'}
                                color={isApprove ? 'green.600' : 'red.600'}
                                px={3}
                                py={1}
                                rounded="full"
                                fontSize="sm"
                            >
                                {isApprove ? 'Approved' : 'Rejected'}
                            </Badge>
                        </Box>
                    </Stack>
                </Box>

                <ModalCloseButton color={closeColor} />
            </ModalContent>
        </Modal>
    );
}
