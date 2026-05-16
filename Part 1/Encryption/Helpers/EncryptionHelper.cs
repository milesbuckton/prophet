using System.Text;

namespace Encryption.Helpers
{
    internal static class EncryptionHelper
    {
        internal const int MaxKeyLength = 13;
        internal const int MaxMessageLength = 255;

        internal static string EncryptMessage(string message, string key)
        {
            ValidateKey(key);
            ValidateMessage(message);

            StringBuilder encryptedMessage = new(message.Length);
            foreach (char letter in message)
            {
                int index = key.IndexOf(letter);
                char encryptedLetter = index >= 0 ? key[(index + 1) % key.Length] : letter;
                encryptedMessage.Append(encryptedLetter);
            }

            return encryptedMessage.ToString();
        }

        private static void ValidateKey(string key)
        {
            ArgumentException.ThrowIfNullOrEmpty(key);

            if (key.Length > MaxKeyLength)
                throw new ArgumentException($"The key must not exceed {MaxKeyLength} characters.", nameof(key));

            foreach (char letter in key)
            {
                if (!char.IsLetter(letter))
                    throw new FormatException("The key must contain only letters.");

                if (!char.IsUpper(letter))
                    throw new FormatException("The key must be all uppercase.");
            }

            if (key.Distinct().Count() != key.Length)
                throw new ArgumentException("The key must not contain repeated letters.", nameof(key));
        }

        private static void ValidateMessage(string message)
        {
            ArgumentException.ThrowIfNullOrEmpty(message);

            if (message.Length > MaxMessageLength)
                throw new ArgumentException($"The message must not exceed {MaxMessageLength} characters.", nameof(message));

            foreach (char letter in message)
            {
                if (letter == ' ')
                    continue;

                if (!char.IsLetter(letter))
                    throw new FormatException("The message must contain only letters.");

                if (!char.IsUpper(letter))
                    throw new FormatException("The message must be all uppercase.");
            }
        }
    }
}
