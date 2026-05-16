using Encryption.Helpers;
using Xunit;

namespace Encryption.Tests
{
    public class EncryptMessageTests
    {
        [Theory]
        [InlineData("ABC", "")]
        [InlineData("", "MOPED")]
        public void EncryptMessage_Empty_ThrowsArgumentException(string message, string key)
        {
            Assert.Throws<ArgumentException>(() => EncryptionHelper.EncryptMessage(message, key));
        }

        [Fact]
        public void EncryptMessage_KeyAtMaxLength_DoesNotThrow()
        {
            string key = "ABCDEFGHIJKLM";

            Assert.Equal(EncryptionHelper.MaxKeyLength, key.Length);
            EncryptionHelper.EncryptMessage("A", key);
        }

        [Fact]
        public void EncryptMessage_KeyExceeds13Characters_ThrowsArgumentException()
        {
            string key = "ABCDEFGHIJKLMN";

            Assert.Equal(EncryptionHelper.MaxKeyLength + 1, key.Length);
            Assert.Throws<ArgumentException>(() => EncryptionHelper.EncryptMessage("ABC", key));
        }

        [Fact]
        public void EncryptMessage_KeyWithRepeatedLetters_ThrowsArgumentException()
        {
            Assert.Throws<ArgumentException>(() => EncryptionHelper.EncryptMessage("ABC", "MOMED"));
        }

        [Fact]
        public void EncryptMessage_LastKeyCharacter_WrapsAroundToFirst()
        {
            string result = EncryptionHelper.EncryptMessage("D", "MOPED");

            Assert.Equal("M", result);
        }

        [Theory]
        [InlineData("hello", "MOPED")]
        [InlineData("ABC", "moped")]
        public void EncryptMessage_Lowercase_ThrowsFormatException(string message, string key)
        {
            Assert.Throws<FormatException>(() => EncryptionHelper.EncryptMessage(message, key));
        }

        [Fact]
        public void EncryptMessage_MessageAtMaxLength_DoesNotThrow()
        {
            string message = new('A', EncryptionHelper.MaxMessageLength);

            EncryptionHelper.EncryptMessage(message, "MOPED");
        }

        [Fact]
        public void EncryptMessage_MessageExceeds255Characters_ThrowsArgumentException()
        {
            Assert.Throws<ArgumentException>(() => EncryptionHelper.EncryptMessage(new('A', EncryptionHelper.MaxMessageLength + 1), "MOPED"));
        }

        [Theory]
        [InlineData("AB!", "MOPED")]
        [InlineData("ABC", "MO1ED")]
        public void EncryptMessage_NonLetter_ThrowsFormatException(string message, string key)
        {
            Assert.Throws<FormatException>(() => EncryptionHelper.EncryptMessage(message, key));
        }

        [Theory]
        [InlineData(null, "MOPED")]
        [InlineData("ABC", null)]
        public void EncryptMessage_Null_ThrowsArgumentNullException(string? message, string? key)
        {
            Assert.Throws<ArgumentNullException>(() => EncryptionHelper.EncryptMessage(message!, key!));
        }

        [Fact]
        public void EncryptMessage_UsesProvidedKey()
        {
            string result = EncryptionHelper.EncryptMessage("A", "AB");

            Assert.Equal("B", result);
        }

        [Fact]
        public void EncryptMessage_ValidMessage_ReturnsEncryptedMessage()
        {
            string result = EncryptionHelper.EncryptMessage("COMPUTER OLYMPIAD", "MOPED");

            Assert.Equal("CPOEUTDR PLYOEIAM", result);
        }

        [Fact]
        public void EncryptMessage_WithLettersNotInKey_ReturnsThemUnchanged()
        {
            string result = EncryptionHelper.EncryptMessage("XYZ", "MOPED");

            Assert.Equal("XYZ", result);
        }
    }
}
